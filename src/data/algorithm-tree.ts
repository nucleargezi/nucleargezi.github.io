export interface AlgorithmTreeDirectory {
  label: string;
  children: AlgorithmTreeNode[];
}

export interface AlgorithmTreeLeaf {
  label: string;
  slug: string;
}

export type AlgorithmTreeNode = AlgorithmTreeDirectory | AlgorithmTreeLeaf;

export const algorithmTree = [
  {
    label: "Math",
    children: [
      {
        label: "Group Theory", 
        children: [
          { label: "Base", slug: "a-20260203_group" },
        ]
      },
    ],
  },
  {
    label: "Other",
    children: [
      { label: "Major Voting", slug: "a-20251025_major_voting" },
    ],
  },
] satisfies AlgorithmTreeNode[];
