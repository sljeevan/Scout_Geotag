String normalizeStatus(String status) {
  switch (status.toUpperCase()) {
    case 'ONGOING':
      return 'Active';
    case 'ON HOLD':
    case 'ON_HOLD':
      return 'On Hold';
    case 'COMPLETED':
      return 'Completed';
    case 'ACTIVE':
      return 'Active';
    case 'CANCELLED':
    case 'CANCELED':
      return 'Cancelled';
    default:
      return status;
  }
}
