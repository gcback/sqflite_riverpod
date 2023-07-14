# sqflite_test

### 플러터에서 sqflite, riverpod를 통해 CRUD를 해보는 테스트앱입니다.

## Getting Started
sqflite 뿐만 아니라 riverpod의 AsyncNotifire를 익혀볼 수 있습니다.

아래 youtube 영상을 참고하였습니다.
- https://www.youtube.com/watch?v=9kbt4SBKhm0&ab_channel=HeyFlutter%E2%80%A4com
 
단순히 CRUD 기능 익히기는 문제없지만 실제 앱에 사용하기 위해서는 몇가지 고려 사항이 있습니다.
1. CRUD API 호출시 Database 인스턴스가 반복적을 생성됩니다.
  그래서 Database 인스턴스는 singleone으로 만들었습니다.

2. Riverpod의 비동기 처리를 이용합니다.
  영상의 모든 CRUD API들은 비동기 API이기 때문에 Future로 반환되는 API 결과값들은 FutureBuilder를 이용해야 합니다.
  따라서 API를 통해 발생하는 결과값은 Riverpod의 비동기상태로 관리하도록 수정하였습니다.
  즉, AsyncNotifier는 상태값들과 CRUD API들 구성하였습니다.
