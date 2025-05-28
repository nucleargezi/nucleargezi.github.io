export const archiveUrl = (id: string, base: string) => {
  const baseUrl = base + (base.endsWith("/") ? "" : "/");
  return `${baseUrl}archive/${id}.pdf`;
};
