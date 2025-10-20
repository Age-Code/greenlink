package org.example.greenlink.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.Arrays;

@Configuration
public class CorsFilterConfiguration {

   @Bean
   public CorsFilter corsFilter() {
      UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
      CorsConfiguration config = new CorsConfiguration();

      config.setAllowCredentials(true); // 인증 정보 포함 허용 (쿠키/헤더 등)
      config.setAllowedOriginPatterns(Arrays.asList("*")); // 모든 출처 허용 (주의)
      config.addAllowedHeader("*"); // 모든 헤더 허용
      config.addAllowedMethod("*"); // 모든 HTTP 메서드 허용 (GET, POST, PUT, DELETE 등)

      // 명시적 허용 헤더들
      String[] arrays = {"Authorization", "RefreshToken"};
      config.setAllowedHeaders(Arrays.asList(arrays));

      // /api/ 이하 모든 경로에 대해 위 설정 적용
      source.registerCorsConfiguration("/api/**", config);

      return new CorsFilter(source);
   }

}