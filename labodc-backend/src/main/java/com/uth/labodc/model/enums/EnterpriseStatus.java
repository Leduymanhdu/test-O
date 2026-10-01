package com.uth.labodc.model.enums;

/**
 * Enterprise verification status enumeration
 */
public enum EnterpriseStatus {
    /**
     * Pending verification - Chờ xác thực
     */
    PENDING,
    
    /**
     * Approved/Verified - Đã duyệt
     */
    APPROVED,
    
    /**
     * Rejected - Từ chối
     */
    REJECTED;
    
    /**
     * Check if enterprise is approved
     */
    public boolean isApproved() {
        return this == APPROVED;
    }
    
    /**
     * Check if enterprise is pending
     */
    public boolean isPending() {
        return this == PENDING;
    }
    
    /**
     * Check if enterprise is rejected
     */
    public boolean isRejected() {
        return this == REJECTED;
    }
}
