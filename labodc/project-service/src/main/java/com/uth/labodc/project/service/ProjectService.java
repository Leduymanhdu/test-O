package com.uth.labodc.project.service;

import com.uth.labodc.project.dto.CreateProjectRequest;
import com.uth.labodc.project.dto.ProjectDetailResponse;
import com.uth.labodc.project.dto.ProjectMemberResponse;
import com.uth.labodc.project.dto.ProjectResponse;
import com.uth.labodc.project.model.*;
import com.uth.labodc.project.repository.ProjectMemberRepository;
import com.uth.labodc.project.repository.ProjectRepository;
import com.uth.labodc.project.security.AuthenticatedUser;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class ProjectService {

    private final ProjectRepository projectRepository;
    private final ProjectMemberRepository projectMemberRepository;

    public ProjectService(ProjectRepository projectRepository, ProjectMemberRepository projectMemberRepository) {
        this.projectRepository = projectRepository;
        this.projectMemberRepository = projectMemberRepository;
    }

    @Transactional
    public ProjectResponse createProject(AuthenticatedUser user, CreateProjectRequest request) {
        Project project = new Project(
                request.name(),
                request.description(),
                user.userId(),
                request.mentorId(),
                ProjectStatus.PENDING
        );
        Project saved = projectRepository.save(project);

        // Auto add enterprise as a member for easier "my projects" and future authorization.
        projectMemberRepository.save(new ProjectMember(saved.getId(), user.userId(), ProjectMemberRole.ENTERPRISE));

        return toResponse(saved);
    }

    @Transactional(readOnly = true)
    public List<ProjectResponse> getMyProjects(AuthenticatedUser user) {
        Map<Long, Project> byId = new LinkedHashMap<>();

        List<Project> owned = projectRepository.findByEnterpriseIdOrderByCreatedAtDesc(user.userId());
        for (Project p : owned) {
            byId.put(p.getId(), p);
        }

        List<ProjectMember> memberships = projectMemberRepository.findByUserId(user.userId());
        if (!memberships.isEmpty()) {
            List<Long> ids = memberships.stream().map(ProjectMember::getProjectId).distinct().toList();
            projectRepository.findAllById(ids).forEach(p -> byId.putIfAbsent(p.getId(), p));
        }

        return byId.values().stream().map(this::toResponse).toList();
    }

    @Transactional
    public ProjectResponse approve(long projectId) {
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Project not found"));
        if (project.getStatus() != ProjectStatus.PENDING) {
            throw new IllegalArgumentException("Only PENDING projects can be approved");
        }
        project.setStatus(ProjectStatus.APPROVED);
        return toResponse(project);
    }

    @Transactional
    public ProjectResponse reject(long projectId) {
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Project not found"));
        if (project.getStatus() != ProjectStatus.PENDING) {
            throw new IllegalArgumentException("Only PENDING projects can be rejected");
        }
        project.setStatus(ProjectStatus.REJECTED);
        return toResponse(project);
    }

    @Transactional
    public ProjectDetailResponse join(long projectId, AuthenticatedUser user) {
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Project not found"));
        if (project.getStatus() != ProjectStatus.APPROVED) {
            throw new IllegalArgumentException("Only APPROVED projects can be joined");
        }

        if (!projectMemberRepository.existsByProjectIdAndUserId(projectId, user.userId())) {
            projectMemberRepository.save(new ProjectMember(projectId, user.userId(), ProjectMemberRole.TALENT));
        }

        return getProject(projectId, user);
    }

    @Transactional(readOnly = true)
    public ProjectDetailResponse getProject(long projectId, AuthenticatedUser user) {
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Project not found"));

        boolean isAdmin = "LAB_ADMIN".equalsIgnoreCase(user.role());
        boolean isOwner = Objects.equals(project.getEnterpriseId(), user.userId());
        boolean isMember = projectMemberRepository.existsByProjectIdAndUserId(projectId, user.userId());
        if (!isAdmin && !isOwner && !isMember) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Not allowed to view this project");
        }

        List<ProjectMemberResponse> members = projectMemberRepository.findByProjectId(projectId)
                .stream()
                .map(m -> new ProjectMemberResponse(m.getUserId(), m.getRole()))
                .collect(Collectors.toList());

        return new ProjectDetailResponse(
                project.getId(),
                project.getName(),
                project.getDescription(),
                project.getEnterpriseId(),
                project.getMentorId(),
                project.getStatus(),
                project.getCreatedAt(),
                members
        );
    }

    private ProjectResponse toResponse(Project project) {
        return new ProjectResponse(
                project.getId(),
                project.getName(),
                project.getDescription(),
                project.getEnterpriseId(),
                project.getMentorId(),
                project.getStatus(),
                project.getCreatedAt()
        );
    }
}
