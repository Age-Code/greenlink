package com.greenlink.greenlink.config;

import com.greenlink.greenlink.security.AiWorkerAuthInterceptor;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
@RequiredArgsConstructor
public class WebMvcConfig implements WebMvcConfigurer {

    private final AiWorkerAuthInterceptor aiWorkerAuthInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(aiWorkerAuthInterceptor)
                .addPathPatterns("/api/ai/**");
    }
}
