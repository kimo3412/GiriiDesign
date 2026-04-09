import { Alova } from '@/utils/http/alova/index';

export interface WorkflowStep {
  stepId?: number;
  workflowId?: number;
  stepName: string;
  stepOrder?: number;
  isStartStep?: number;
  isEndStep?: number;
  nodeDescription?: string;
  allowedActions?: string;
  needImageUpload?: number;
  visibleToClient?: number;
  expectedDurationDays?: number | null;
}

export interface Workflow {
  workflowId?: number;
  categoryId: number;
  workflowName: string;
}

export interface WorkflowVO {
  workflow: Workflow | null;
  steps: WorkflowStep[];
}

export interface WorkflowSaveDTO {
  workflowName: string;
  steps: WorkflowStep[];
}

export const getWorkflow = (categoryId: number) => {
  return Alova.Get<WorkflowVO>(`/v1/admin/categories/${categoryId}/workflow`);
};

export const saveWorkflow = (categoryId: number, data: WorkflowSaveDTO) => {
  return Alova.Post<void>(`/v1/admin/categories/${categoryId}/workflow`, data);
};
