package com.uth.labodc.gateway.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

public final class JwtTokenValidator {

    private final SecretKey key;
    private final long clockSkewMillis;

    public JwtTokenValidator(String secret, long clockSkewSeconds) {
        if (secret == null || secret.isBlank()) {
            throw new IllegalArgumentException("security.jwt.secret is required");
        }
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.clockSkewMillis = Math.max(0, clockSkewSeconds) * 1000L;
    }

    public Jws<Claims> parseAndValidate(String token) {
        Jws<Claims> jws = Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token);

        Date exp = jws.getBody().getExpiration();
        if (exp != null) {
            long now = System.currentTimeMillis();
            if (exp.getTime() + clockSkewMillis < now) {
                throw new IllegalArgumentException("Token expired");
            }
        }
        return jws;
    }
}
