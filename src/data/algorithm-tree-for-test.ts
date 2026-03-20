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
        label: "Formal Power Series",
        children: [
          // { label: "FPS Note 0", slug: "a-20251216_fps0"},
          // { label: "FPS Note 1", slug: "a-20251217_fps1"},
          // { label: "FPS Note 2", slug: "a-20251218_fps2"},
          // { label: "FPS Training Rec", slug: "a-20251225_fps_train_rec"},
          // { label: "EGF Note", slug: "a-20260117_fps_egf"},
          // { label: "FPS 24 Rec", slug: "a-20260201_fps24"},
        ]
      },
      {
        label: "Group Theory", 
        children: [
          { label: "Base", slug: "a-20260203_group" },
        ]
      },
    ],
  },
  {
    label: "Game",
    children: [
      // { label: "Base", slug: "a-20260202_game" },
    ],
  },
  {
    label: "Other",
    children: [
      // { label: "Major Voting", slug: "a-20251025_major_voting" },
    ],
  },
] satisfies AlgorithmTreeNode[];
