package com.uth.labodc.project.controller;

import com.uth.labodc.project.dto.CreateProjectRequest;
import com.uth.labodc.project.dto.ProjectDetailResponse;
import com.uth.labodc.project.dto.ProjectResponse;
import com.uth.labodc.project.security.AuthenticatedUser;
import com.uth.labodc.project.service.ProjectService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/projects")
public class ProjectController {

    private final ProjectService projectService;

    public ProjectController(ProjectService projectService) {
        this.projectService = projectService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ProjectResponse create(@Valid @RequestBody CreateProjectRequest request, Authentication authentication) {
        AuthenticatedUser user = (AuthenticatedUser) authentication.getPrincipal();
        return projectService.createProject(user, request);
    }

    @GetMapping("/my")
    public List<ProjectResponse> my(Authentication authentication) {
        AuthenticatedUser user = (AuthenticatedUser) authentication.getPrincipal();
        return projectService.getMyProjects(user);
    }

    @PutMapping("/{id}/approve")
    public ProjectResponse approve(@PathVariable("id") long id) {
        return projectService.approve(id);
    }

    @PutMapping("/{id}/reject")
    public ProjectResponse reject(@PathVariable("id") long id) {
        return projectService.reject(id);
    }

    @PostMapping("/{id}/join")
    public ProjectDetailResponse join(@PathVariable("id") long id, Authentication authentication) {
        AuthenticatedUser user = (AuthenticatedUser) authentication.getPrincipal();
        return projectService.join(id, user);
    }

    @GetMapping("/{id}")
    public ProjectDetailResponse get(@PathVariable("id") long id, Authentication authentication) {
        AuthenticatedUser user = (AuthenticatedUser) authentication.getPrincipal();
        return projectService.getProject(id, user);
    }
}
