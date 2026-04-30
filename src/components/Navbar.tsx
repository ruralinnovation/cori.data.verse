"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import styles from "./Navbar.module.css";

const NAV_ITEMS = [
  { title: "Home", url: "/" },
  { title: "Charts & Data", url: "/charts-and-data" },
  { title: "Projects", url: "/projects" },
  { title: "R Packages", url: "/packages" },
  { title: "Resources", url: "/resources" },
  { title: "About", url: "/about" },
];

export default function Navbar() {
  const pathname = usePathname();

  return (
    <header className={styles.header}>
      <div className={styles.container}>
        <div className={styles.branding}>
          <Link href="/" className={styles.siteTitle}>
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src="/assets/images/Logo-Mark_CORI_Cream.svg"
              alt="CORI Logo"
              className={styles.logo}
              width={45}
              height={45}
            />
            <span>Rural Dataverse</span>
          </Link>

        </div>

        <nav className={styles.nav}>
          <ul>
            {NAV_ITEMS.map((item) => (
              <li key={item.url}>
                <Link
                  href={item.url}
                  className={
                    pathname === item.url ||
                    (item.url !== "/" && pathname.startsWith(item.url))
                      ? styles.active
                      : undefined
                  }
                >
                  {item.title}
                </Link>
              </li>
            ))}
          </ul>
        </nav>
      </div>
    </header>
  );
}
