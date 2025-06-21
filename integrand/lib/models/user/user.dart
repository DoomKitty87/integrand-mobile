// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class User {
  User({required String name, required String picture}) 

  factory User.fromJson(Map<String, Object?> json) {
    return User(
      name: "default", 
      picture: "null",
    );
  }
}
