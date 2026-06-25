enum PlaceDetailRole { leader, member }

PlaceDetailRole? placeDetailRoleFromQuery(String? value) {
  return switch (value) {
    'leader' => PlaceDetailRole.leader,
    'member' || 'team' => PlaceDetailRole.member,
    _ => null,
  };
}
