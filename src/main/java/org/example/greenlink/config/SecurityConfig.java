package org.example.greenlink.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.example.greenlink.repository.UserRepository;
import org.example.greenlink.security.*;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.www.BasicAuthenticationFilter;

@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
@Configuration
public class SecurityConfig {
	
	private final UserRepository userRepository;
	private final CorsFilterConfiguration corsFilterConfiguration;
	private final ObjectMapper objectMapper;
	private final AuthService authService;
	private final ExternalProperties externalProperties;

	/**
	 * 비밀번호 암호화
	 */
	@Bean
	BCryptPasswordEncoder bCryptPasswordEncoder() {
		return new BCryptPasswordEncoder();
	}
	
    /**
	 *  Spring Security 권한 설정.
	 */
	@Bean
	SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
		http.headers().frameOptions().sameOrigin(); // iframe 보안 설정

		http
				// CSRF 비활성화 (REST API)
				.csrf(AbstractHttpConfigurer::disable)
				// 모든 요청 허용
				.authorizeHttpRequests(auth -> auth.anyRequest().permitAll())
				// 세션 사용 안 함 (STATELESS)
				.sessionManagement(management -> management.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
				// 기본 로그인폼 비활성화
				.formLogin(AbstractHttpConfigurer::disable)
				// HTTP Basic 인증 비활성화
				.httpBasic(AbstractHttpConfigurer::disable)
				// CORS 필터 삽입
				.addFilter(corsFilterConfiguration.corsFilter())
				// 아래 정의한 커스텀 필터들 삽입 (CustomDsl)
				.apply(new CustomDsl());

		return http.build();
	}
					
	public class CustomDsl extends AbstractHttpConfigurer<CustomDsl, HttpSecurity> {
		
	    /**
		 *  커스텀 필터 설정
		 */
		@Override
		public void configure(HttpSecurity http) throws Exception {
			AuthenticationManager authenticationManager = http.getSharedObject(AuthenticationManager.class);

			JwtAuthenticationFilter jwtAuthenticationFilter = new JwtAuthenticationFilter(authenticationManager, objectMapper, authService, externalProperties);
			jwtAuthenticationFilter.setFilterProcessesUrl("/api/login");
			
			http.addFilter(corsFilterConfiguration.corsFilter())
					// 로그인 처리 필터
					.addFilter(jwtAuthenticationFilter)
					// JWT 검증 필터
					.addFilter(new JwtAuthorizationFilter(authenticationManager, userRepository, authService, externalProperties))
					// 예외 핸들링 필터
					.addFilterBefore(new FilterExceptionHandlerFilter(), BasicAuthenticationFilter.class);
		}
		
	}

}