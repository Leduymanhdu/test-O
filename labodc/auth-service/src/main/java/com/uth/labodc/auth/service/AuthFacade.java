package com.uth.labodc.auth.service;

import com.uth.labodc.auth.dto.AuthResponse;
import com.uth.labodc.auth.dto.LoginRequest;
import com.uth.labodc.auth.dto.RegisterRequest;
import com.uth.labodc.auth.dto.ValidateResponse;
import com.uth.labodc.auth.model.UserCredential;
import com.uth.labodc.auth.repository.UserCredentialRepository;
import io.jsonwebtoken.Claims;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthFacade {

    private final UserCredentialRepository repository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthFacade(UserCredentialRepository repository, PasswordEncoder passwordEncoder, JwtService jwtService) {
        this.repository = repository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    public void register(RegisterRequest request) {
        if (repository.existsByEmailIgnoreCase(request.email())) {
            throw new IllegalArgumentException("Email đã tồn tại");
        }
        String encoded = passwordEncoder.encode(request.password());
        UserCredential saved = repository.save(new UserCredential(request.email(), encoded, request.role()));
        // token is returned on login; keep register minimal
    }

    public AuthResponse login(LoginRequest request) {
        UserCredential credential = repository.findByEmailIgnoreCase(request.email())
                .orElseThrow(() -> new IllegalArgumentException("Sai email hoặc mật khẩu"));

        if (!passwordEncoder.matches(request.password(), credential.getPassword())) {
            throw new IllegalArgumentException("Sai email hoặc mật khẩu");
        }

        String token = jwtService.generateToken(String.valueOf(credential.getId()), credential.getEmail(), credential.getRole());
        return new AuthResponse(token, "Bearer", credential.getEmail(), credential.getRole());
    }

    public ValidateResponse validate(String token) {
        Claims claims = jwtService.validateAndGetClaims(token);
        String userId = claims.getSubject();
        String email = claims.get("email", String.class);
        String role = claims.get("role", String.class);
        return new ValidateResponse(true, userId, email, role);
    }
}
