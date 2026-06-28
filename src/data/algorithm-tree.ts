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
    label: "Data Structure",
    children: [
      {
        label: "Bitset",
        children: [
          { label: "Bitmask Range Prod", slug: "a-20260327_bitmask_range_prod" },
        ],
      },
      {
        label: "Segment tree",
        children: [
          { label: "Segment Tree Based on N_ary Tree", slug: "a-20260323_a_wide_seg_tree" },
        ],
      },
      {
        label: "Heap",
        children: [
          { label: "Radix Heap", slug: "a-20260321_fheap" },
        ],
      }
    ],
  },
  {
    label: "Math",
    children: [
      {
        label: "Formal Power Series",
        children: [
          { label: "FPS Note 0", slug: "a-20251216_fps0" },
          { label: "FPS Note 1", slug: "a-20251217_fps1" },
          { label: "FPS Note 2", slug: "a-20251218_fps2" },
          { label: "FPS Training Rec", slug: "a-20251225_fps_train_rec" },
          { label: "EGF Note", slug: "a-20260117_fps_egf" },
          { label: "FPS 24 Rec", slug: "a-20260201_fps24" },
        ]
      },
      {
        label: "Set Power Series",
        children: [
          { label: "SPS Note 0", slug: "a-20260601_sps0" },
        ]
      },
      {
        label: "Combinatorics",
        children: [
          { label: "q-Binomial Coefficient", slug: "a-20260621_q_binom" },
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
    label: "String",
    children: [
      { label: "SAM", slug: "a-20260620_sam" },
    ],
  },
  {
    label: "Game",
    children: [
      { label: "Base", slug: "a-20260202_game" },
    ],
  },
  {
    label: "Other",
    children: [
      { label: "Major Voting", slug: "a-20251025_major_voting" },
    ],
  },
] satisfies AlgorithmTreeNode[];
