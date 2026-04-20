import type { ProjectMeta } from "@/types";

interface ProjectSidebarProps {
  project: ProjectMeta;
}

export default function ProjectSidebar({ project }: ProjectSidebarProps) {
  return (
    <aside className="sidebar">
      {project.projectUrl && (
        <div className="sidebar-section">
          <h3>Project</h3>
          <a
            href={project.projectUrl}
            className="btn btn-primary"
            target="_blank"
            rel="noopener noreferrer"
            style={{ display: "block", textAlign: "center" }}
          >
            View Project
          </a>
        </div>
      )}

      <div className="sidebar-section">
        <h3>Details</h3>
        <dl>
          {project.status && (
            <>
              <dt>Status</dt>
              <dd>
                <span className="badge">{project.status}</span>
              </dd>
            </>
          )}
        </dl>
      </div>

      {project.team && project.team.length > 0 && (
        <div className="sidebar-section">
          <h3>Team</h3>
          <ul style={{ listStyle: "none", padding: 0 }}>
            {project.team.map((member) => (
              <li key={member} style={{ marginBottom: "0.25em" }}>
                {member}
              </li>
            ))}
          </ul>
        </div>
      )}

      {project.usesDatasets && project.usesDatasets.length > 0 && (
        <div className="sidebar-section">
          <h3>Uses Datasets</h3>
          <div>
            {project.usesDatasets.map((ds) => (
              <span key={ds} className="badge" style={{ marginBottom: "0.3em" }}>
                {ds}
              </span>
            ))}
          </div>
        </div>
      )}

      {project.usesPackages && project.usesPackages.length > 0 && (
        <div className="sidebar-section">
          <h3>Uses Packages</h3>
          <div>
            {project.usesPackages.map((pkg) => (
              <span key={pkg} className="badge" style={{ marginBottom: "0.3em" }}>
                {pkg}
              </span>
            ))}
          </div>
        </div>
      )}
    </aside>
  );
}
