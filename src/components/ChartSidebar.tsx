import type { ChartInfo } from "@/types";

interface ChartSidebarProps {
  chart?: ChartInfo;
}

export default function ChartSidebar({ chart }: ChartSidebarProps) {
  if (!chart) return null;

  return (
    <aside className="sidebar">
      {chart.sourceUrl && (
        <div className="sidebar-section">
          <h3>View Chart</h3>
          <a
            href={chart.sourceUrl}
            className="btn btn-primary"
            target="_blank"
            rel="noopener noreferrer"
          >
            Open Source Data
          </a>
        </div>
      )}

      <div className="sidebar-section">
        <h3>Details</h3>
        <dl>
          {chart.chartType && (
            <>
              <dt>Chart Type</dt>
              <dd>{chart.chartType}</dd>
            </>
          )}
          {chart.interactive !== undefined && (
            <>
              <dt>Interactive</dt>
              <dd>{chart.interactive ? "Yes" : "No"}</dd>
            </>
          )}
          {chart.dataSource && (
            <>
              <dt>Data Source</dt>
              <dd>{chart.dataSource}</dd>
            </>
          )}
        </dl>
      </div>
    </aside>
  );
}
