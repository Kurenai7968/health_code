build_android:
	flutter build appbundle --release

build_ios:
	flutter build ipa --release

icon:
	flutter pub run flutter_launcher_icons:main

translation:
	flutter pub run translation2json