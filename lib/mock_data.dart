import 'package:playlistmaster/entities/detail_playlist.dart';

import 'entities/playlist.dart';
import 'entities/singer.dart';
import 'entities/song.dart';

class MockData {
  static List<Singer> singers = [
    Singer(
      id: '1',
      mid: '1',
      name: 'Giant Parakeet',
    ),
    Singer(
      id: '2',
      mid: '2',
      name: 'Little Chickadee',
    ),
    Singer(
      id: '3',
      mid: '3',
      name: 'Mysterious Owlet',
    ),
    Singer(
      id: '4',
      mid: '4',
      name: 'Lovely Budgerigar',
    ),
    Singer(
      id: '5',
      mid: '5',
      name: 'Funny Blue Jay',
    ),
    Singer(
      id: '6',
      mid: '6',
      name: 'Smart Columbidae',
    ),
    Singer(
      id: '7',
      mid: '7',
      name: 'Beautiful Hummingbirds',
    ),
    Singer(
      id: '8',
      mid: '8',
      name: 'Intelligent Toucans',
    ),
    Singer(
      id: '9',
      mid: '9',
      name: 'Adorable Finches',
    ),
    Singer(
      id: '10',
      mid: '10',
      name: 'Vibrant Bluebirds',
    ),
  ];

  static List<Song> songs = [
    Song(
      name: 'Parrot',
      singers: [singers[0]],
      coverUri: 'assets/images/songs_cover/parrot.jpeg',
      link: 'assets/audios/lyrics.mp3',
      // TODO: fix this, test lyrics.
      // link: 'assets/audios/parrot.mp3',
    ),
    Song(
      name: 'Tit',
      singers: [singers[1]],
      coverUri: 'assets/images/songs_cover/tit.jpeg',
      link: 'assets/audios/tit.mp3',
    ),
    Song(
      name: 'Owl',
      singers: [singers[2]],
      coverUri: 'assets/images/songs_cover/owl.jpeg',
      link: 'assets/audios/owl.mp3',
    ),
    Song(
      name: 'Budgerigar',
      singers: [singers[3]],
      coverUri: 'assets/images/songs_cover/budgerigar.jpeg',
      link: 'assets/audios/budgerigar.mp3',
    ),
    Song(
      name: 'Blue Jay',
      singers: [singers[4]],
      coverUri: 'assets/images/songs_cover/bluejay.jpeg',
      link: 'assets/audios/bluejay.mp3',
    ),
    Song(
      name: 'Columbidae',
      singers: [singers[5]],
      coverUri: 'assets/images/songs_cover/columbidae.jpeg',
      link: 'assets/audios/columbidae.mp3',
    ),
    Song(
      name: 'Hummingbirds',
      singers: [singers[6]],
      coverUri: 'assets/images/songs_cover/hummingbirds.jpeg',
      link: 'assets/audios/hummingbirds.mp3',
    ),
    Song(
      name: 'Toucans',
      singers: [singers[7]],
      coverUri: 'assets/images/songs_cover/toucans.jpeg',
      link: 'assets/audios/toucans.mp3',
    ),
    Song(
      name: 'Finches',
      singers: [singers[8]],
      coverUri: 'assets/images/songs_cover/finches.jpeg',
      link: 'assets/audios/finches.mp3',
    ),
    Song(
      name: 'Bluebirds',
      singers: [singers[9]],
      coverUri: 'assets/images/songs_cover/bluebirds.jpeg',
      link: 'assets/audios/bluebirds.mp3',
    ),
  ];

  static List<Playlist> playlists = [
    Playlist(
      name: 'Bird',
      coverImage: 'assets/images/playlist_cover/bird.png',
      songsCount: 20,
      dirId: 1,
      tid: '1',
    ),
    Playlist(
      name: 'Zebra',
      coverImage: 'assets/images/playlist_cover/zebra.png',
      songsCount: 24,
      dirId: 2,
      tid: '2',
    ),
    Playlist(
      name: 'Cat',
      coverImage: 'assets/images/playlist_cover/cat.png',
      songsCount: 3,
      dirId: 3,
      tid: '3',
    ),
    Playlist(
      name: 'Owl',
      coverImage: 'assets/images/playlist_cover/owl.png',
      songsCount: 68,
      dirId: 4,
      tid: '4',
    ),
    Playlist(
      name: 'Shark',
      coverImage: 'assets/images/playlist_cover/shark.png',
      songsCount: 23,
      dirId: 5,
      tid: '5',
    ),
    Playlist(
      name: 'Panther',
      coverImage: 'assets/images/playlist_cover/panther.png',
      songsCount: 30,
      dirId: 6,
      tid: '6',
    ),
    Playlist(
      name: 'Lion',
      coverImage: 'assets/images/playlist_cover/lion.png',
      songsCount: 89,
      dirId: 7,
      tid: '7',
    ),
    Playlist(
      name: 'Fox',
      coverImage: 'assets/images/playlist_cover/fox.png',
      songsCount: 169,
      dirId: 8,
      tid: '8',
    ),
    Playlist(
      name: 'Dog',
      coverImage: 'assets/images/playlist_cover/dog.png',
      songsCount: 72,
      dirId: 9,
      tid: '9',
    ),
    Playlist(
      name: 'Dolphin',
      coverImage: 'assets/images/playlist_cover/dolphin.png',
      songsCount: 83,
      dirId: 10,
      tid: '10',
    ),
    Playlist(
      name: 'Rabbit',
      coverImage: 'assets/images/playlist_cover/rabbit.png',
      songsCount: 24,
      dirId: 11,
      tid: '11',
    ),
    Playlist(
      name: 'Elephant',
      coverImage: 'assets/images/playlist_cover/elephant.png',
      songsCount: 75,
      dirId: 12,
      tid: '12',
    ),
    Playlist(
      name: 'Wolf',
      coverImage: 'assets/images/playlist_cover/wolf.png',
      songsCount: 98,
      dirId: 13,
      tid: '13',
    ),
    Playlist(
      name: 'Dove',
      coverImage: 'assets/images/playlist_cover/dove.png',
      songsCount: 56,
      dirId: 14,
      tid: '14',
    ),
    Playlist(
      name: 'Snake',
      coverImage: 'assets/images/playlist_cover/snake.png',
      songsCount: 65,
      dirId: 15,
      tid: '15',
    ),
    Playlist(
      name: 'Bear',
      coverImage: 'assets/images/playlist_cover/bear.png',
      songsCount: 32,
      dirId: 16,
      tid: '16',
    ),
    Playlist(
      name: 'Bee',
      coverImage: 'assets/images/playlist_cover/bee.png',
      songsCount: 58,
      dirId: 17,
      tid: '17',
    ),
    Playlist(
      name: 'Panda',
      coverImage: 'assets/images/playlist_cover/panda.png',
      songsCount: 80,
      dirId: 18,
      tid: '18',
    ),
    Playlist(
      name: 'Koala',
      coverImage: 'assets/images/playlist_cover/koala.png',
      songsCount: 7,
      dirId: 19,
      tid: '19',
    ),
    Playlist(
      name: 'Lizard',
      coverImage: 'assets/images/playlist_cover/lizard.png',
      songsCount: 73,
      dirId: 20,
      tid: '20',
    ),
  ];

  static DetailPlaylist detail_playlist = DetailPlaylist(
    name: 'Bird',
    description:
        'A bird does not sing because it has an answer, it sings because it has a song.',
    coverImage: 'assets/images/playlist_cover/bird.png',
    songsCount: 20,
    dirId: 1,
    tid: '1',
    songs: songs,
  );

  static const normalLyric = """[ti:If I Didn't Love You]
[ar:Jason Aldean/Carrie Underwood]
[al:If I Didn't Love You]
[by:]
[offset:0]
[00:00.45]If I Didn't Love You - Jason Aldean/Carrie Underwood
[00:02.49]
[00:11.15]I wouldn't mind being alone
[00:12.85]
[00:13.68]I wouldn't keep checking my phone
[00:16.29]Wouldn't take the long way home
[00:18.00]Just to drive myself crazy
[00:20.56]
[00:21.53]I wouldn't be losing sleep
[00:23.27]
[00:24.24]Remembering everything
[00:26.57]Everything you said to me
[00:28.62]Like I'm doing lately
[00:31.10]You you wouldn't be all
[00:34.55]
[00:35.34]All that I want
[00:37.08]
[00:37.82]Baby I can let go
[00:39.45]
[00:40.36]If I didn't love you I'd be good by now
[00:45.28]I'd be better than barely getting by somehow
[00:49.81]
[00:50.77]Yeah it would be easy not to miss you
[00:54.57]Wonder about who's with you
[00:57.20]Turn the want you off
[00:58.61]Whenever I want to
[01:01.21]If I didn't love you
[01:05.26]
[01:06.32]If I didn't love you
[01:09.33]
[01:13.71]I wouldn't still cry sometimes
[01:15.86]
[01:16.51]Wouldn't have to fake a smile
[01:18.26]
[01:18.83]Play it off and tell a lie
[01:20.97]When somebody asked how I've been
[01:24.17]I'd try to find someone new
[01:25.70]Someone new
[01:26.82]It should be something I can do
[01:28.53]I can do
[01:29.37]Baby if it weren't for you
[01:31.22]I wouldn't be in the state that I'm in
[01:33.78]Yeah you
[01:34.37]
[01:35.17]You wouldn't be all
[01:37.10]
[01:37.99]All that I want
[01:39.62]
[01:40.41]Baby I could let go
[01:42.98]If I didn't love you I'd be good by now
[01:47.85]I'd be better than barely getting by somehow
[01:52.47]
[01:53.42]Yeah it would be easy not to miss you
[01:57.14]Wonder about who's with you
[01:59.75]Turn the want you off
[02:01.06]Whenever I want to
[02:03.30]
[02:03.82]If I didn't love you
[02:07.87]
[02:08.91]If I didn't love you
[02:11.08]Oh if I didn't love you
[02:14.59]It wouldn't be so hard to see you
[02:18.05]Know how much I need you
[02:20.68]Wouldn't hate that I still feel like I do
[02:24.26]
[02:24.77]If I didn't love you
[02:26.70]Oh if I didn't love you
[02:30.14]If I didn't love you
[02:32.77]Hmm mm-hmm
[02:34.57]
[02:35.09]If I didn't love you I'd be good by now
[02:39.96]I'd be better than barely getting by somehow
[02:44.88]
[02:45.56]Yeah it would be easy not to miss you
[02:49.33]Wonder about who's with you
[02:51.96]Turn the want you off
[02:53.24]Whenever I want to
[02:56.04]If I didn't love you
[02:59.32]Yeah ayy ayy
[03:01.21]If I didn't love you
[03:03.28]Oh if I didn't love you
[03:06.56]If I didn't love you
[03:09.07]If I didn't love you
[03:11.67]If I didn't love you""";

  static const issue1 = """
L!011588917494188
<?xml version="1.0" encoding="utf-8"?>
<QrcInfos>
<QrcHeadInfo SaveTime="221" Version="100"/>
<LyricInfo LyricCount="1">
<Lyric_1 LyricType="1" LyricContent="[ti:beolsseo 12si]
[ar:cheongha]
[al:beolsseo 12si]
[by:]
[offset:0]
[0,827]beol(0,103)sseo(103,103) (206,103)12(309,103)si(412,103) - (515,103)cheong(618,103)ha(721,103)
[827,827]词(827,68)：(895,68)beul(963,68)raek(1031,68)a(1099,68)i(1167,68)deu(1235,68)pil(1303,68)seung(1371,68)/(1439,68)jeon(1507,68)gun(1575,68)
[1654,827]曲(1654,68)：(1722,68)beul(1790,68)raek(1858,68)a(1926,68)i(1994,68)deu(2062,68)pil(2130,68)seung(2198,68)/(2266,68)jeon(2334,68)gun(2402,68)
[2481,827]编(2481,165)曲(2646,165)：(2811,165)ra(2976,165)do(3141,165)
[3308,827]Synthesizer (3308,206)Performed：(3514,206)ra(3720,206)do(3926,206)
[4135,827]Bass (4135,206)Performed：(4341,206)ra(4547,206)do(4753,206)
[4962,827]Drums (4962,206)Performed：(5168,206)ra(5374,206)do(5580,206)
[5789,827]Background (5789,165)Vocals：(5954,165)gim(6119,165)bo(6284,165)a(6449,165)
[6616,827]Recording (6616,91)Engineer：(6707,91)jeong(6798,91)eun(6889,91)gyeong(6980,91) (7071,91)at (7162,91)Ingrid (7253,91)Studio(7344,91)
[7443,827]Mixing (7443,31)Engineer：(7474,31)go(7505,31)hyeon(7536,31)jeong(7567,31) ((7598,31)Assist. (7629,31)gim(7660,31)gyeong(7691,31)hwan(7722,31), (7753,31)gim(7784,31)jun(7815,31)sang(7846,31), (7877,31)jeon(7908,31)jin(7939,31), (7970,31)jeong(8001,31)gi(8032,31)un(8063,31)) (8094,31)at (8125,31)Koko (8156,31)Sound (8187,31)Studio(8218,31)

[99999999,9999999]***Lyrics are from third-parties***(99999999,2000)
"/>
</LyricInfo>
</QrcInfos>
""";

  static const advancedLyric = """[ti:If I Didn't Love You]
[ar:Jason Aldean/Carrie Underwood]
[al:If I Didn't Love You]
[by:]
[offset:0]
[457,2039]If (457,177)I (634,182)Didn't (816,210)Love (1026,183)You - (1209,207)Jason (1416,217)Aldean/(1633,208)Carrie (1841,230)Underwood(2071,425)
[11155,1697]I (11155,161)wouldn't (11316,223)mind (11539,345)being (11884,423)alone(12307,545)
[13684,2128]I (13684,159)wouldn't (13843,272)keep (14115,345)checking (14460,330)my (14790,318)phone(15108,704)
[16292,1712]Wouldn't (16292,192)take (16484,287)the (16771,216)long (16987,384)way (17371,153)home(17524,480)
[18004,2560]Just (18004,192)to (18196,193)drive (18389,367)myself (18756,608)crazy(19364,1200)
[21532,1744]I (21532,177)wouldn't (21709,255)be (21964,296)losing (22260,608)sleep(22868,408)
[24243,1856]Remembering (24243,665)everything(24908,1191)
[26575,1856]Everything (26575,681)you (27256,199)said (27455,344)to (27799,169)me(27968,463)
[28626,2256]Like (28626,182)I'm (28808,343)doing (29151,649)lately(29800,1082)
[31108,3449]You (31108,831)you (32386,322)wouldn't (32708,584)be (33292,408)all(33700,857)
[35349,1736]All (35349,320)that (35669,176)I (35845,432)want(36277,808)
[37821,1632]Baby (37821,144)I (37965,376)can (38341,161)let (38502,407)go(38909,544)
[40360,4482]If (40360,205)I (40565,330)didn't (40895,566)love (41461,704)you (42165,326)I'd (42491,310)be (42801,343)good (43144,528)by (43672,449)now(44121,721)
[45280,4537]I'd (45280,216)be (45496,305)better (45801,591)than (46392,384)barely (46776,984)getting (47760,609)by (48369,455)somehow(48824,993)
[50777,3473]Yeah (50777,241)it (51018,272)would (51290,424)be (51714,193)easy (51907,1015)not (52922,272)to (53194,320)miss (53514,408)you(53922,328)
[54570,2264]Wonder (54570,548)about (55118,716)who's (56058,144)with (56202,272)you(56474,360)
[57202,1416]Turn (57202,217)the (57419,144)want (57563,303)you (57866,290)off(58156,462)
[58618,2209]Whenever (58618,768)I (59386,328)want (59714,680)to(60394,433)
[61210,4056]If (61210,216)I (61426,295)didn't (61721,641)love (62362,656)you(63018,2248)
[66329,3009]If (66329,233)I (66562,288)didn't (66850,695)love (67545,696)you(68241,1097)
[73714,2147]I (73714,193)wouldn't (73907,215)still (74122,320)cry (74442,304)sometimes(74746,1115)
[76517,1752]Wouldn't (76517,232)have (76749,168)to (76917,176)fake (77093,336)a (77429,208)smile(77637,632)
[78838,1836]Play (78838,151)it (78989,152)off (79141,365)and (79506,208)tell (79714,288)a (80002,201)lie(80203,471)
[80978,2744]When (80978,147)somebody (81125,813)asked (81938,672)how (82610,321)I've (82931,327)been(83258,464)
[84170,1531]I'd (84170,161)try (84331,191)to (84522,152)find (84674,240)someone (84914,602)new(85516,185)
[85701,864]Someone (85701,536)new(86237,328)
[86828,1576]It (86828,129)should (86957,200)be (87157,152)something (87309,248)I (87557,256)can (87813,335)do(88148,256)
[88533,648]I (88533,160)can (88693,192)do(88885,296)
[89370,1669]Baby (89370,77)if (89447,448)it (89895,160)weren't (90055,359)for (90414,265)you(90679,360)
[91223,2561]I (91223,152)wouldn't (91375,176)be (91551,224)in (91775,280)the (92055,314)state (92369,719)that (93279,176)I'm (93455,192)in(93647,137)
[93784,586]Yeah (93784,143)you(93927,443)
[95175,1928]You (95175,208)wouldn't (95383,511)be (95894,421)all(96315,788)
[97998,1626]All (97998,305)that (98303,272)I (98575,392)want(98967,657)
[100415,2072]Baby (100415,176)I (100591,272)could (100863,208)let (101071,480)go(101551,936)
[102983,4424]If (102983,216)I (103199,264)didn't (103463,675)love (104138,629)you (104767,336)I'd (105103,313)be (105416,335)good (105751,558)by (106309,450)now(106759,648)
[107855,4622]I'd (107855,232)be (108087,304)better (108391,656)than (109047,329)barely (109376,974)getting (110350,649)by (110999,472)somehow(111471,1006)
[113420,3448]Yeah (113420,208)it (113628,241)would (113869,255)be (114124,392)easy (114516,1008)not (115524,297)to (115821,360)miss (116181,303)you(116484,384)
[117148,2313]Wonder (117148,625)about (117773,784)who's (118557,281)with (118838,246)you(119084,377)
[119756,1307]Turn (119756,233)the (119989,152)want (120141,242)you (120383,362)off(120745,318)
[121063,2242]Whenever (121063,961)I (122024,343)want (122367,651)to(123018,287)
[123822,4049]If (123822,240)I (124062,250)didn't (124312,710)love (125022,625)you(125647,2224)
[128911,2177]If (128911,296)I (129207,327)didn't (129534,673)love (130207,657)you(130864,224)
[131088,3112]Oh (131088,335)if (131423,345)I (131768,321)didn't (132089,678)love (132767,688)you(133455,745)
[134592,3151]It (134592,232)wouldn't (134824,616)be (135440,649)so (136089,295)hard (136384,408)to (136792,209)see (137001,335)you(137336,407)
[138055,2321]Know (138055,625)how (138680,328)much (139008,304)I (139312,328)need (139640,312)you(139952,424)
[140680,3581]Wouldn't (140680,327)hate (141007,304)that (141311,312)I (141623,290)still (141913,308)feel (142221,320)like (142541,304)I (142845,336)do(143181,1080)
[144773,1934]If (144773,199)I (144972,241)didn't (145213,640)love (145853,638)you(146491,216)
[146707,3272]Oh (146707,648)if (147355,175)I (147530,248)didn't (147778,688)love (148466,657)you(149123,856)
[150146,2465]If (150146,161)I (150307,223)didn't (150530,579)love (151109,677)you(151786,825)
[152779,1791]Hmm (152779,576)mm-(153355,690)hmm(154045,525)
[155099,4549]If (155099,208)I (155307,296)didn't (155603,704)love (156307,728)you (157035,289)I'd (157324,267)be (157591,347)good (157938,536)by (158474,510)now(158984,664)
[159969,4920]I'd (159969,240)be (160209,305)better (160514,639)than (161153,344)barely (161497,999)getting (162496,608)by (163104,512)somehow(163616,1273)
[165569,3474]Yeah (165569,216)it (165785,232)would (166017,289)be (166306,391)easy (166697,1001)not (167698,282)to (167980,333)miss (168313,336)you(168649,394)
[169337,2255]Wonder (169337,568)about (169905,695)who's (170600,330)with (170930,342)you(171272,320)
[171968,1273]Turn (171968,184)the (172152,161)want (172313,256)you (172569,312)off(172881,360)
[173241,2384]Whenever (173241,928)I (174169,344)want (174513,656)to(175169,456)
[176046,3122]If (176046,196)I (176242,270)didn't (176512,640)love (177152,657)you(177809,1359)
[179320,1480]Yeah (179320,394)ayy (179714,350)ayy(180064,736)
[181216,2073]If (181216,201)I (181417,265)didn't (181682,726)love (182408,610)you(183018,271)
[183289,3080]Oh (183289,363)if (183652,308)I (183960,320)didn't (184280,689)love (184969,671)you(185640,729)
[186560,2328]If (186560,216)I (186776,233)didn't (187009,610)love (187619,654)you(188273,615)
[189072,2360]If (189072,202)I (189274,247)didn't (189521,680)love (190201,655)you(190856,576)
[191672,3477]If (191672,210)I (191882,262)didn't (192144,682)love (192826,663)you(193489,1660)""";

  static const transLyric = """[ti:If I Didn't Love You]
[ar:Jason Aldean/Carrie Underwood]
[al:If I Didn't Love You]
[by:]
[offset:0]
[00:00.45]腾讯音乐享有本翻译作品的著作权
[00:02.49]
[00:11.15]我不介意孤身一人
[00:12.85]
[00:13.68]我不会一直查看我手机
[00:16.29]我不会兜远路回家
[00:18.00]只为让自己陷入疯狂中
[00:20.56]
[00:21.53]我也不会辗转反侧
[00:23.27]
[00:24.24]回忆起你对我
[00:26.57]说的每字每句
[00:28.62]最近我如这般
[00:31.10]你不会是
[00:34.55]
[00:35.34]我渴望的所有
[00:37.08]
[00:37.82]宝贝我能放下所有
[00:39.45]
[00:40.36]如果我从未爱上你 此刻的我不会如此伤心
[00:45.28]我会过得比现在好 现在的我像行尸走肉般
[00:49.81]
[00:50.77]或许不去想你会让我好受点
[00:54.57]不去想谁在你身边
[00:57.20]想切断对你的思念
[00:58.61]无论何时
[01:01.21]如果我从未爱上你
[01:05.26]
[01:06.32]如果我从未爱上你
[01:09.33]
[01:13.71]我就不会有时仍会淌泪
[01:15.86]
[01:16.51]不必佯装笑颜
[01:18.26]
[01:18.83]当某人问起我近况
[01:20.97]我会敷衍了事
[01:24.17]我试着去另觅新欢
[01:25.70]另觅新欢
[01:26.82]我本应做得到
[01:28.53]能够做到
[01:29.37]宝贝若不是因为你
[01:31.22]我就不会落得如此下场
[01:33.78]没错是你
[01:34.37]
[01:35.17]你不会是
[01:37.10]
[01:37.99]我渴望的所有
[01:39.62]
[01:40.41]宝贝我能放下所有
[01:42.98]如果我从未爱上你 此刻的我不会如此伤心
[01:47.85]我会过得比现在好 现在的我像行尸走肉般
[01:52.47]
[01:53.42]或许不去想你会让我好受点
[01:57.14]不去想谁在你身边
[01:59.75]想切断对你的思念
[02:01.06]无论何时
[02:03.30]
[02:03.82]如果我从未爱上你
[02:07.87]
[02:08.91]如果我从未爱上你
[02:11.08]如果我从未爱上你
[02:14.59]看见你时我就不会如此难受
[02:18.05]你知道我有多需要你吗
[02:20.68]我就不会恨自己仍对你保留感觉
[02:24.26]
[02:24.77]如果我从未爱上你
[02:26.70]如果我从未爱上你
[02:30.14]如果我从未爱上你
[02:32.77]//
[02:34.57]
[02:35.09]如果我从未爱上你 此刻的我不会如此伤心
[02:39.96]我会过得比现在好 现在的我像行尸走肉般
[02:44.88]
[02:45.56]或许不去想你会让我好受点
[02:49.33]不去想谁在你身边
[02:51.96]想切断对你的思念
[02:53.24]无论何时
[02:56.04]如果我从未爱上你
[02:59.32]//
[03:01.21]如果我从未爱上你
[03:03.28]如果我从未爱上你
[03:06.56]如果我从未爱上你
[03:09.07]如果我从未爱上你
[03:11.67]如果我从未爱上你""";
}
