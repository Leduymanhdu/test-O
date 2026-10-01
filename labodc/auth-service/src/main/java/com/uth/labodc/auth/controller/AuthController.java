package com.uth.labodc.auth.controller;

import com.uth.labodc.auth.dto.AuthResponse;
import com.uth.labodc.auth.dto.LoginRequest;
import com.uth.labodc.auth.dto.RegisterRequest;
import com.uth.labodc.auth.dto.ValidateResponse;
import com.uth.labodc.auth.service.AuthFacade;
import jakarta.validation.Valid;
import org.springframework.http.HttpHeaders;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthFacade authFacade;

    public AuthController(AuthFacade authFacade) {
        this.authFacade = authFacade;
    }

    @PostMapping("/register")
    public void register(@Valid @RequestBody RegisterRequest request) {
        authFacade.register(request);
    }

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest request) {
        return authFacade.login(request);
    }

    @GetMapping("/validate")
    public ValidateResponse validate(@RequestHeader(HttpHeaders.AUTHORIZATION) String authorization) {
        String token = extractToken(authorization);
        return authFacade.validate(token);
    }

    private String extractToken(String authorization) {
        if (authorization == null || !authorization.startsWith("Bearer ")) {
            throw new IllegalArgumentException("Missing Bearer token");
        }
        return authorization.substring("Bearer ".length()).trim();
    }
}
