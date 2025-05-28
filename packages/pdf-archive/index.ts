// Do not write code directly here, instead use the `src` folder!
// Then, use this file to export everything you want your user to access.

import ArchiveList from "./src/ArchiveList.astro";
import ArchiveButton from "./src/ArchiveButton.astro";
import ArchiveRef from "./src/ArchiveRef.astro";

export interface ArchiveProps {
  pdfArchives: {
    id: string;
    data: {
      title: string;
      date: Date;
      indices?: string[];
    };
  }[];
}

export { ArchiveList, ArchiveButton, ArchiveRef };
