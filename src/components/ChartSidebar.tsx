import Link from "next/link";
import type { ChartMeta } from "@/types";

interface ChartSidebarProps {
  metadata: ChartMeta;
}

export default function ChartSidebar({ metadata }: ChartSidebarProps) {
  const { chart, usesDatasets, usesPackages, producedBy } = metadata;

  return (
    <aside className="sidebar">
      {chart?.sourceUrl && (
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
          {chart?.chartType && (
            <>
              <dt>Chart Type</dt>
              <dd>{chart.chartType}</dd>
            </>
          )}
          {chart?.interactive !== undefined && (
            <>
              <dt>Interactive</dt>
              <dd>{chart.interactive ? "Yes" : "No"}</dd>
            </>
          )}
          {chart?.dataSource && (
            <>
              <dt>Data Source</dt>
              <dd>{chart.dataSource}</dd>
            </>
          )}
          {producedBy && (
            <>
              <dt>Produced By</dt>
              <dd>
                <Link href={`/projects/${producedBy}`}>
                  {producedBy}
                </Link>
              </dd>
            </>
          )}
        </dl>
      </div>

      {usesDatasets && usesDatasets.length > 0 && (
        <div className="sidebar-section">
          <h3>Uses Datasets</h3>
          <div>
            {usesDatasets.map((ds) => (
              <Link
                key={ds}
                href={`/charts-and-data/datasets/${ds}`}
                className="badge"
                style={{ display: "inline-block", marginBottom: "0.3em", marginRight: "0.3em" }}
              >
                {ds}
              </Link>
            ))}
          </div>
        </div>
      )}

      {usesPackages && usesPackages.length > 0 && (
        <div className="sidebar-section">
          <h3>Uses Packages</h3>
          <div>
            {usesPackages.map((pkg) => (
              <span key={pkg} className="badge" style={{ marginBottom: "0.3em", marginRight: "0.3em" }}>
                {pkg}
              </span>
            ))}
          </div>
        </div>
      )}
    </aside>
  );
}
