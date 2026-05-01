import type { Metadata } from "next";
import { Bitter } from "next/font/google";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import "./globals.css";

const basePath = process.env.NEXT_PUBLIC_BASE_PATH || "";

const bitter = Bitter({
  subsets: ["latin"],
  variable: "--font-heading",
  display: "swap",
});

export const metadata: Metadata = {
  title: {
    default: "Rural Dataverse",
    template: "%s | Rural Dataverse",
  },
  description:
    "Your hub for rural innovation data, tools, research, and analysis. Explore datasets, R packages, projects, and blog posts from the CORI MDA team.",
  icons: {
    icon: `${basePath}/assets/images/Logo-Mark_Black.png`,
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className={bitter.variable}>
      <head>
        <link rel="stylesheet" href={`${basePath}/assets/fonts.css`} />
      </head>
      <body>
        <Navbar />
        <main>{children}</main>
        <Footer />
      </body>
    </html>
  );
}
