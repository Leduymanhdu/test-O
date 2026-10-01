package com.uth.labodc.user.model;

import jakarta.persistence.*;

@Entity
@Table(name = "user_profiles", indexes = {
        @Index(name = "idx_user_profiles_role", columnList = "role"),
        @Index(name = "idx_user_profiles_email", columnList = "email")
})
public class UserProfile {

    @Id
    private Long id;

    @Column(nullable = false, length = 200)
    private String fullName;

    @Column(nullable = false, length = 200)
    private String email;

    @Column(nullable = false, length = 50)
    private String role;

    @Column(columnDefinition = "text")
    private String skills;

    @Column(length = 500)
    private String portfolioUrl;

    protected UserProfile() {
    }

    public UserProfile(Long id, String fullName, String email, String role, String skills, String portfolioUrl) {
        this.id = id;
        this.fullName = fullName;
        this.email = email;
        this.role = role;
        this.skills = skills;
        this.portfolioUrl = portfolioUrl;
    }

    public Long getId() {
        return id;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getSkills() {
        return skills;
    }

    public void setSkills(String skills) {
        this.skills = skills;
    }

    public String getPortfolioUrl() {
        return portfolioUrl;
    }

    public void setPortfolioUrl(String portfolioUrl) {
        this.portfolioUrl = portfolioUrl;
    }
}
