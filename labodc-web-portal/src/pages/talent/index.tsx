import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import TalentDashboard from './TalentDashboard';
import TalentProfile from './TalentProfile';
import ProjectsBrowse from './ProjectsBrowse';
import MyProjects from './MyProjects';
import TalentLeaderDashboard from './TalentLeaderDashboard';

const TalentRoutes: React.FC = () => {
  return (
    <Routes>
      <Route path="/" element={<Navigate to="/talent/dashboard" replace />} />
      <Route path="/dashboard" element={<TalentDashboard />} />
      <Route path="/profile" element={<TalentProfile />} />
      <Route path="/projects" element={<ProjectsBrowse />} />
      <Route path="/my-projects" element={<MyProjects />} />
      <Route path="/leader/:projectId" element={<TalentLeaderDashboard />} />
    </Routes>
  );
};

export default TalentRoutes;
