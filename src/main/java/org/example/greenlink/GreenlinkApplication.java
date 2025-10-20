package org.example.greenlink;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@EnableJpaAuditing
@SpringBootApplication
public class GreenlinkApplication {

    public static void main(String[] args) {
        SpringApplication.run(GreenlinkApplication.class, args);
    }

}
