package com.uth.labodc.auth.model;

import jakarta.persistence.*;

@Entity
@Table(name = "user_credentials", uniqueConstraints = {
        @UniqueConstraint(name = "uk_user_credentials_email", columnNames = "email")
})
public class UserCredential {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 200)
    private String email;

    @Column(nullable = false, length = 200)
    private String password;

    @Column(nullable = false, length = 50)
    private String role;

    protected UserCredential() {
    }

    public UserCredential(String email, String password, String role) {
        this.email = email;
        this.password = password;
        this.role = role;
    }

    public Long getId() {
        return id;
    }

    public String getEmail() {
        return email;
    }

    public String getPassword() {
        return password;
    }

    public String getRole() {
        return role;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setRole(String role) {
        this.role = role;
    }
}
