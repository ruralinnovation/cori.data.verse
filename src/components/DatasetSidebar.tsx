import type { DatasetInfo } from "@/types";

interface DatasetSidebarProps {
  dataset?: DatasetInfo;
}

export default function DatasetSidebar({ dataset }: DatasetSidebarProps) {
  if (!dataset) return null;

  return (
    <aside className="sidebar">
      {dataset.sourceUrl && (
        <div className="sidebar-section">
          <h3>Access Data</h3>
          <a
            href={dataset.sourceUrl}
            className="btn btn-primary"
            target="_blank"
            rel="noopener noreferrer"
            style={{ display: "block", textAlign: "center" }}
          >
            Go to Source
          </a>
        </div>
      )}

      <div className="sidebar-section">
        <h3>Details</h3>
        <dl>
          {dataset.source && (
            <>
              <dt>Source</dt>
              <dd>{dataset.source}</dd>
            </>
          )}
          {dataset.accessMethod && (
            <>
              <dt>Access Method</dt>
              <dd>{dataset.accessMethod}</dd>
            </>
          )}
          {dataset.updateFrequency && (
            <>
              <dt>Update Frequency</dt>
              <dd>{dataset.updateFrequency}</dd>
            </>
          )}
          {dataset.geographicLevel && (
            <>
              <dt>Geographic Level</dt>
              <dd>{dataset.geographicLevel}</dd>
            </>
          )}
        </dl>
      </div>

      {dataset.dataFormat && dataset.dataFormat.length > 0 && (
        <div className="sidebar-section">
          <h3>Formats</h3>
          <div>
            {dataset.dataFormat.map((fmt) => (
              <span key={fmt} className="badge" style={{ marginBottom: "0.3em" }}>
                {fmt}
              </span>
            ))}
          </div>
        </div>
      )}
    </aside>
  );
}
