// Pagination Hook
import { useState } from 'react';

interface UsePaginationProps {
  initialPage?: number;
  initialPageSize?: number;
  totalElements?: number;
}

export function usePagination({
  initialPage = 1,
  initialPageSize = 10,
  totalElements = 0,
}: UsePaginationProps = {}) {
  const [page, setPage] = useState(initialPage);
  const [pageSize, setPageSize] = useState(initialPageSize);

  const totalPages = Math.ceil(totalElements / pageSize);

  const goToPage = (newPage: number) => {
    if (newPage >= 1 && newPage <= totalPages) {
      setPage(newPage);
    }
  };

  const nextPage = () => {
    goToPage(page + 1);
  };

  const previousPage = () => {
    goToPage(page - 1);
  };

  const changePageSize = (newSize: number) => {
    setPageSize(newSize);
    setPage(1); // Reset to first page when changing page size
  };

  return {
    page,
    pageSize,
    totalPages,
    setPage: goToPage,
    nextPage,
    previousPage,
    changePageSize,
  };
}
