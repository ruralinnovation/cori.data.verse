import type { PackageInfo } from "@/types";

interface PackageSidebarProps {
  pkg?: PackageInfo;
}

export default function PackageSidebar({ pkg }: PackageSidebarProps) {
  if (!pkg) return null;

  return (
    <aside className="sidebar">
      {pkg.installCommand && (
        <div className="sidebar-section">
          <h3>Installation</h3>
          <pre style={{ fontSize: "0.8em" }}>
            <code>{pkg.installCommand}</code>
          </pre>
        </div>
      )}

      <div className="sidebar-section">
        <h3>Links</h3>
        <ul style={{ listStyle: "none", padding: 0 }}>
          {pkg.githubUrl && (
            <li style={{ marginBottom: "0.5em" }}>
              <a href={pkg.githubUrl} target="_blank" rel="noopener noreferrer">
                GitHub Repository
              </a>
            </li>
          )}
        </ul>
      </div>

      <div className="sidebar-section">
        <h3>Details</h3>
        <dl>
          {pkg.version && (
            <>
              <dt>Version</dt>
              <dd>{pkg.version}</dd>
            </>
          )}
          {pkg.status && (
            <>
              <dt>Status</dt>
              <dd>
                <span className="badge">{pkg.status}</span>
              </dd>
            </>
          )}
          {pkg.maintainer && (
            <>
              <dt>Maintainer</dt>
              <dd>{pkg.maintainer}</dd>
            </>
          )}
        </dl>
      </div>
    </aside>
  );
}
