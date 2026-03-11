import { Alova } from '@/utils/http/alova/index';

export interface CustomField {
  fieldId?: number;
  categoryId: number;
  label: string;
  fieldKey: string;
  fieldType: string; // text, number, select, date, image
  unit?: string;
  options?: any;
  placeholder?: string;
  isRequired: number;
  sortOrder?: number;
}

export const getFieldList = (categoryId: number) => {
  return Alova.Get<CustomField[]>(`/v1/admin/categories/${categoryId}/fields`);
};

export const saveFieldList = (categoryId: number, fields: CustomField[]) => {
  return Alova.Post<void>(`/v1/admin/categories/${categoryId}/fields`, fields);
};

export const deleteField = (categoryId: number, fieldId: number) => {
  return Alova.Delete<void>(`/v1/admin/categories/${categoryId}/fields/${fieldId}`);
};
