enum ThemeMode {
  light,
  dark,
}

//
enum UserKarma {
  comment(1),
  deletePost(-1),
  textPost(2),
  imagePost(3),
  awardPost(5),
  linkPost(3);

  final int karma;
  const UserKarma(this.karma);
}
