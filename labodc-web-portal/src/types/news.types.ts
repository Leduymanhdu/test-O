/**
 * News & Events Types
 * Các kiểu dữ liệu cho tin tức và sự kiện
 */

export interface INews {
  id: string;
  title: string;
  slug: string;
  excerpt?: string;
  imageUrl: string;
  publishedAt: string;
  category: NewsCategory;
  author?: string;
  viewCount?: number;
}

export enum NewsCategory {
  PARTNERSHIP = 'PARTNERSHIP', // Hợp tác
  EVENT = 'EVENT', // Sự kiện
  ACHIEVEMENT = 'ACHIEVEMENT', // Thành tựu
  ANNOUNCEMENT = 'ANNOUNCEMENT', // Thông báo
  GENERAL = 'GENERAL', // Tin tức chung
}

export interface INewsListResponse {
  items: INews[];
  total: number;
  page: number;
  pageSize: number;
}

export interface INewsDetail extends INews {
  content: string;
  tags?: string[];
  relatedNews?: INews[];
}
