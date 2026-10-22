/**
 * News Service
 * Service để lấy tin tức và sự kiện
 */

import { INews, NewsCategory } from '@/types/news.types';

/**
 * Lấy danh sách tin tức mới nhất
 * TODO: Thay thế bằng API call thực tế khi backend sẵn sàng
 */
export const getLatestNews = (limit: number = 5): INews[] => {
  // Mock data dựa trên thông tin thực tế của UTH
  const mockNews: INews[] = [
    {
      id: '29476',
      title: 'UTH bắt tay CT Group nghiên cứu khoa học, kiến tạo nguồn nhân lực công nghệ cho tương lai',
      slug: 'uth-bat-tay-ct-group-nghien-cuu-khoa-hoc-kien-tao-nguon-nhan-luc-cong-nghe-cho-tuong-lai',
      imageUrl: 'https://images.unsplash.com/photo-1556761175-b413da4baf72?w=400&h=250&fit=crop',
      publishedAt: '2026-01-23',
      category: NewsCategory.PARTNERSHIP,
      viewCount: 245,
    },
    {
      id: '29475',
      title: 'Đảng bộ Trường Đại học Giao thông vận tải TP.HCM: Tăng tốc chuyển đổi số, tập trung nhân lực chất lượng cao năm 2026',
      slug: 'dang-bo-truong-dai-hoc-giao-thong-van-tai-tphcm-tang-toc-chuyen-doi-so',
      imageUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=400&h=250&fit=crop',
      publishedAt: '2026-01-22',
      category: NewsCategory.ANNOUNCEMENT,
      viewCount: 312,
    },
    {
      id: '29474',
      title: 'UTH ký kết Biên bản thỏa thuận hợp tác toàn diện với Công ty TNHH SX TM DV Bảo Phúc Center (T&C Auto)',
      slug: 'uth-ky-ket-bien-ban-thoa-thuan-hop-tac-toan-dien-voi-cong-ty-bao-phuc-center',
      imageUrl: 'https://images.unsplash.com/photo-1560179707-f14e90ef3623?w=400&h=250&fit=crop',
      publishedAt: '2026-01-22',
      category: NewsCategory.PARTNERSHIP,
      viewCount: 189,
    },
    {
      id: '29473',
      title: 'UTH kết nối TIACA định hình kỹ năng tương lai ngành vận tải hàng không',
      slug: 'uth-ket-noi-tiaca-dinh-hinh-ky-nang-tuong-lai-nganh-van-tai-hang-khong',
      imageUrl: 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=400&h=250&fit=crop',
      publishedAt: '2026-01-21',
      category: NewsCategory.EVENT,
      viewCount: 267,
    },
    {
      id: '29472',
      title: 'UTH ký kết hợp tác với Công ty TNHH Sản xuất và Kinh doanh VinFast, thúc đẩy đào tạo nguồn nhân lực ô tô điện chất lượng cao',
      slug: 'uth-ky-ket-hop-tac-voi-vinfast-thuc-day-dao-tao-nguon-nhan-luc-o-to-dien',
      imageUrl: 'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=400&h=250&fit=crop',
      publishedAt: '2026-01-15',
      category: NewsCategory.PARTNERSHIP,
      viewCount: 543,
    },
  ];

  return mockNews.slice(0, limit);
};

/**
 * Lấy chi tiết tin tức theo ID
 * TODO: Thay thế bằng API call thực tế
 */
export const getNewsById = (id: string): INews | null => {
  const news = getLatestNews(10);
  return news.find((n) => n.id === id) || null;
};

/**
 * Lấy tin tức theo danh mục
 */
export const getNewsByCategory = (category: NewsCategory, limit: number = 5): INews[] => {
  const news = getLatestNews(10);
  return news.filter((n) => n.category === category).slice(0, limit);
};

/**
 * Format ngày tháng theo định dạng Việt Nam
 */
export const formatNewsDate = (dateString: string): string => {
  const date = new Date(dateString);
  const day = date.getDate().toString().padStart(2, '0');
  const month = (date.getMonth() + 1).toString().padStart(2, '0');
  const year = date.getFullYear();
  return `${day}/${month}/${year}`;
};

/**
 * Lấy nhãn danh mục
 */
export const getCategoryLabel = (category: NewsCategory): string => {
  const labels: Record<NewsCategory, string> = {
    [NewsCategory.PARTNERSHIP]: 'Hợp tác',
    [NewsCategory.EVENT]: 'Sự kiện',
    [NewsCategory.ACHIEVEMENT]: 'Thành tựu',
    [NewsCategory.ANNOUNCEMENT]: 'Thông báo',
    [NewsCategory.GENERAL]: 'Tin tức chung',
  };
  return labels[category];
};

/**
 * Lấy màu badge cho danh mục
 */
export const getCategoryColor = (category: NewsCategory): string => {
  const colors: Record<NewsCategory, string> = {
    [NewsCategory.PARTNERSHIP]: 'blue',
    [NewsCategory.EVENT]: 'green',
    [NewsCategory.ACHIEVEMENT]: 'gold',
    [NewsCategory.ANNOUNCEMENT]: 'orange',
    [NewsCategory.GENERAL]: 'default',
  };
  return colors[category];
};
