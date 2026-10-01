package com.uth.labodc.service;

import com.uth.labodc.model.entity.User;

public interface UserService {
    User getUserById(Long userId);
    User getUserByEmail(String email);
}
