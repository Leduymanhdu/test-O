package com.uth.labodc;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class LabOdcApplication {
    public static void main(String[] args) {
        SpringApplication.run(LabOdcApplication.class, args);
    }
}
