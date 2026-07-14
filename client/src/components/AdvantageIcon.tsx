import React from "react";

interface AdvantageIconProps {
  icon?: string | null;
  className?: string;
}

export function AdvantageIcon({ icon, className }: AdvantageIconProps) {
  if (!icon) return null;

  if (icon.startsWith("fa-")) {
    return <i className={`fa-solid ${icon} ${className || ""}`} aria-hidden="true" />;
  }

  return <span className={className}>{icon}</span>;
}
