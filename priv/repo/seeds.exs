# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     AlbumTags.Repo.insert!(%AlbumTags.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias AlbumTags.Accounts
alias AlbumTags.Albums
alias AlbumTags.Lists

# ====== create test user ======
{:ok, carl} = Accounts.create_user(
  %{
    email: "carl@dafox.com",
    provider: "google",
    token: "c7be72feb30608cf810cc9bce2d856dc839a11bb"
  }
)

# ====== create test albums ======
{:ok, emery} = Albums.create_album(
  %{
    apple_album_id: 716394623,
    apple_url: "https://itunes.apple.com/us/album/the-question/716394623",
    title: "The Question",
    artist: "Emery",
    release_date: "2005-08-02",
    record_company: "Tooth & Nail (TNN)",
    cover: "https://is3-ssl.mzstatic.com/image/thumb/Music4/v4/db/cd/a9/dbcda9bf-6551-a37d-0d57-3c4455b9d8dd/00724386060457.jpg/{w}x{h}bb.jpeg"
  }
)

{:ok, treos} = Albums.create_album(
  %{
    apple_album_id: 1278421921,
    apple_url: "https://itunes.apple.com/us/album/between-the-heart-and-the-synapse/1278421921",
    title: "Between the Heart and the Synapse",
    artist: "The Receiving End of Sirens",
    release_date: "2005-04-26",
    record_company: "Triple Crown Records",
    cover: "https://is5-ssl.mzstatic.com/image/thumb/Music118/v4/64/16/fe/6416febd-6a38-d961-0fc8-5e29f40e1e24/646920305865.jpg/{w}x{h}bb.jpeg"
  }
)

{:ok, artifex_pereo} = Albums.create_album(
  %{
    apple_album_id: 1135092935,
    apple_url: "https://itunes.apple.com/us/album/passengers/1135092935",
    title: "Passengers",
    artist: "Artifex Pereo",
    release_date: "2016-09-09",
    record_company: "Tooth & Nail Records",
    cover: "https://is2-ssl.mzstatic.com/image/thumb/Music20/v4/c5/64/ce/c564ce15-0e87-458c-cbb0-9941d65b5648/886446002583.jpg/{w}x{h}bb.jpeg"
  }
)

# ====== create test songs ======
Albums.create_songs([
  %{
    duration: "3:31",
    name: "So Cold I Could See My Breath",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/Music7/v4/bb/aa/8e/bbaa8ecf-c6fa-c14f-8dec-c4114c1f4e39/mzaf_7024513181233691069.plus.aac.p.m4a",
    track_number: 1,
    # album_id: emery.id
  },
  %{
    duration: "3:51",
    name: "Playing With Fire",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/Music1/v4/26/57/72/265772b1-1cc2-7fbd-783d-bd6ab88b0cbf/mzaf_7820572234580713718.plus.aac.p.m4a",
    track_number: 2,
    # album_id: emery.id
  },
  %{
    duration: "3:04",
    name: "Returning the Smile You Have Had from the Start",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/Music1/v4/ee/55/6f/ee556fe4-8186-b8c7-2687-2fd0f06c8355/mzaf_3641708595458221862.plus.aac.p.m4a",
    track_number: 3,
    # album_id: emery.id
  },
  %{
    duration: "3:30",
    name: "Studying Politics",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/Music7/v4/29/fa/06/29fa065a-e936-ac53-d19c-3e261ae34fa4/mzaf_521595224995800094.plus.aac.p.m4a",
    track_number: 4,
    # album_id: emery.id
  },
  %{
    duration: "3:22",
    name: "Left With Alibis and Lying Eyes",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/Music7/v4/0b/2e/21/0b2e21f4-56cf-5377-1463-229327ebd1c4/mzaf_7454326967578127424.plus.aac.p.m4a",
    track_number: 5,
    # album_id: emery.id
  },
  %{
    duration: "2:42",
    name: "Listening to Freddie Mercury",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/Music7/v4/47/8f/00/478f0062-5421-dc43-3028-055a69d2135b/mzaf_603428502145090945.plus.aac.p.m4a",
    track_number: 6,
    # album_id: emery.id
  },
  %{
    duration: "4:04",
    name: "The Weakest",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/Music7/v4/a6/e2/fe/a6e2febd-1c17-820a-87de-6dbd0f0759a5/mzaf_8997738435877061626.plus.aac.p.m4a",
    track_number: 7,
    # album_id: emery.id
  },
  %{
    duration: "3:17",
    name: "Miss Behavin'",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/Music5/v4/09/fd/bd/09fdbde1-3c74-7fed-5f81-cba9c1041cd6/mzaf_3196419263995720941.plus.aac.p.m4a",
    track_number: 8,
    # album_id: emery.id
  },
  %{
    duration: "0:32",
    name: "In Between 4th and 2nd Street",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview128/v4/b8/fd/3a/b8fd3a25-6960-9dbf-4287-0117692e72fa/mzaf_7025872716886053815.plus.aac.p.m4a",
    track_number: 9,
    # album_id: emery.id
  },
  %{
    duration: "3:28",
    name: "The Terrible Secret",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/Music7/v4/c5/a6/4f/c5a64f5a-8780-8664-3fe5-4b8a5070ce5a/mzaf_7142239023229574773.plus.aac.p.m4a",
    track_number: 10,
    # album_id: emery.id
  },
  %{
    duration: "3:56",
    name: "In a Lose, Lose Situation",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/Music7/v4/1a/1e/4e/1a1e4ee2-0ed4-650d-d692-f266c4094af5/mzaf_432556276441230459.plus.aac.p.m4a",
    track_number: 11,
    # album_id: emery.id
  },
  %{
    duration: "5:42",
    name: "In a Win Win Situation",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/Music1/v4/b4/d8/63/b4d86392-2b50-f75e-74d3-e16f5dc56e7f/mzaf_4825499374263026879.plus.aac.p.m4a",
    track_number: 12,
    # album_id: emery.id
  },
], emery)

Albums.create_songs([
  %{
    duration: "0:42",
    name: "Prologue",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview128/v4/84/11/79/84117993-0fde-3190-aea5-cf268839a3be/mzaf_5364606596573014297.plus.aac.p.m4a",
    track_number: 1,
    # album_id: treos.id
  },
  %{
    duration: "5:18",
    name: "Planning a Prison Break",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview128/v4/63/b8/de/63b8de66-4b6e-ff9b-5d1a-02615008e057/mzaf_2089337172950933763.plus.aac.p.m4a",
    track_number: 2,
    # album_id: treos.id
  },
  %{
    duration: "5:30",
    name: "The Rival Cycle",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview118/v4/f3/2b/e3/f32be351-a03d-7b2c-c26d-11ad52d0e711/mzaf_5950277141345527544.plus.aac.p.m4a",
    track_number: 3,
    # album_id: treos.id
  },
  %{
    duration: "4:18",
    name: "The Evidence",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview118/v4/c9/ff/39/c9ff391d-44a8-d949-b9d5-954245cddb7e/mzaf_8123122366422342587.plus.aac.p.m4a",
    track_number: 4,
    # album_id: treos.id
  },
  %{
    duration: "6:26",
    name: "The War of All Against All",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview118/v4/b5/14/47/b5144774-0e54-d329-3356-cd78182f93cf/mzaf_8326755625664541665.plus.aac.p.m4a",
    track_number: 5,
    # album_id: treos.id
  },
  %{
    duration: "5:06",
    name: "…then I Defy You, Stars",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview128/v4/1f/ba/84/1fba848a-75c9-b551-0e82-48f02b4736f4/mzaf_7833459142211101935.plus.aac.p.m4a",
    track_number: 6,
    # album_id: treos.id
  },
  %{
    duration: "4:32",
    name: "Intermission",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview128/v4/2c/0f/ab/2c0fabc1-7251-eefa-1801-d678d2d0e1ea/mzaf_8298630447485188274.plus.aac.p.m4a",
    track_number: 7,
    # album_id: treos.id
  },
  %{
    duration: "5:55",
    name: "This Armistice",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview128/v4/41/fb/6f/41fb6f14-7d29-f2e7-8b93-5f4946c991f2/mzaf_5590177618864765480.plus.aac.p.m4a",
    track_number: 8,
    # album_id: treos.id
  },
  %{
    duration: "4:48",
    name: "Broadcast Quality",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview128/v4/6f/93/be/6f93be8d-428c-1ecd-1c13-61d410f47283/mzaf_2510448356135193462.plus.aac.p.m4a",
    track_number: 9,
    # album_id: treos.id
  },
  %{
    duration: "5:20",
    name: "Flee the Factory",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview128/v4/b9/09/87/b90987c8-7430-db77-1ad5-f0bb6642d894/mzaf_6813004919727173579.plus.aac.p.m4a",
    track_number: 10,
    # album_id: treos.id
  },
  %{
    duration: "4:11",
    name: "Dead Men Tell No Tales",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview128/v4/52/8f/fe/528ffe56-c02d-20bc-a8af-ce18ab40d176/mzaf_2707511471445801204.plus.aac.p.m4a",
    track_number: 11,
    # album_id: treos.id
  },
  %{
    duration: "5:33",
    name: "Venona",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview128/v4/4f/9b/0b/4f9b0b40-90ed-d38c-55ab-e35929d99bde/mzaf_5341156671521988473.plus.aac.p.m4a",
    track_number: 12,
    # album_id: treos.id
  },
  %{
    duration: "13:09",
    name: "Epilogue",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview128/v4/3c/77/8a/3c778a82-1e46-3fc7-e864-b5fc954fae26/mzaf_1429922882565713865.plus.aac.p.m4a",
    track_number: 13,
    # album_id: treos.id
  },
], treos)

Albums.create_songs([
  %{
    duration: "1:22",
    name: "Re-Entry",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview18/v4/59/8f/90/598f900e-7680-0ae1-fceb-f7b625a007bb/mzaf_1890668327033099712.plus.aac.p.m4a",
    track_number: 1,
    # album_id: artifex_pereo.id
  },
  %{
    duration: "4:28",
    name: "First, Do No Harm",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview30/v4/df/8b/01/df8b011f-b726-4068-d564-84b45b7f4d4a/mzaf_5074158511125823447.plus.aac.p.m4a",
    track_number: 2,
    # album_id: artifex_pereo.id
  },
  %{
    duration: "4:15",
    name: "Paper Ruled All",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview18/v4/ab/b5/35/abb53537-0ba0-5b40-409d-3fb3c8b3bf29/mzaf_1567277391762296483.plus.aac.p.m4a",
    track_number: 3,
    # album_id: artifex_pereo.id
  },
  %{
    duration: "4:08",
    name: "Space Between Thoughts",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview60/v4/0b/7b/c3/0b7bc3a2-97de-eb05-c658-70219decdec9/mzaf_4775777883739589052.plus.aac.p.m4a",
    track_number: 4,
    # album_id: artifex_pereo.id
  },
  %{
    duration: "4:55",
    name: "Soft Weapons",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview20/v4/10/36/e2/1036e204-6c8b-4f7b-ad67-89ff9f6a99ac/mzaf_1886228701994084966.plus.aac.p.m4a",
    track_number: 5,
    # album_id: artifex_pereo.id
  },
  %{
    duration: "3:54",
    name: "Age of Loneliness",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview18/v4/5b/63/77/5b6377bb-201b-988b-f201-a6b7be74fd2c/mzaf_5360565487023481904.plus.aac.p.m4a",
    track_number: 6,
    # album_id: artifex_pereo.id
  },
  %{
    duration: "3:40",
    name: "The Coefficient of Inefficiency",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview30/v4/b6/0a/c8/b60ac828-1378-e901-2bc1-a52ccad9fcf6/mzaf_2668157000556294761.plus.aac.p.m4a",
    track_number: 7,
    # album_id: artifex_pereo.id
  },
  %{
    duration: "4:01",
    name: "Enterprise of Empire",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview20/v4/13/5a/f0/135af0a5-14c7-14ee-8fda-f8845e5dc2d5/mzaf_6495659933544022981.plus.aac.p.m4a",
    track_number: 8,
    # album_id: artifex_pereo.id
  },
  %{
    duration: "4:12",
    name: "As We Look On",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview18/v4/c8/66/3b/c8663b5e-1ba5-422a-2bfd-32d9fe72cd61/mzaf_6345076749026238429.plus.aac.p.m4a",
    track_number: 9,
    # album_id: artifex_pereo.id
  },
  %{
    duration: "4:25",
    name: "As History Would Have It",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview60/v4/98/dc/70/98dc7047-0260-c031-7561-c381d325ba2a/mzaf_6805554579321322410.plus.aac.p.m4a",
    track_number: 10,
    # album_id: artifex_pereo.id
  },
  %{
    duration: "4:59",
    name: "Static Color",
    preview: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview18/v4/97/ab/66/97ab6689-04b0-5f31-abfd-c7a5d08c016a/mzaf_510549031882612482.plus.aac.p.m4a",
    track_number: 11,
    # album_id: artifex_pereo.id
  },
], artifex_pereo)

# ====== create test tags ======
{:ok, emo_tag} = Albums.create_tag(%{text: "Emo", user_id: carl.id, custom_genre: true})
{:ok, screamo_tag} = Albums.create_tag(%{text: "Screamo", user_id: carl.id, custom_genre: true})
{:ok, guitars_tag} = Albums.create_tag(%{text: "Noodley Guitars", user_id: carl.id, custom_genre: false})
{:ok, tag_2005} = Albums.create_tag(%{text: "2005", user_id: carl.id, custom_genre: false})

# ====== associate test tags with test albums ======
Albums.add_tag_to_album(%{album_id: emery.id, tag_id: emo_tag.id, user_id: carl.id})
Albums.add_tag_to_album(%{album_id: treos.id, tag_id: emo_tag.id, user_id: carl.id})
Albums.add_tag_to_album(%{album_id: emery.id, tag_id: screamo_tag.id, user_id: carl.id})
Albums.add_tag_to_album(%{album_id: treos.id, tag_id: guitars_tag.id, user_id: carl.id})
Albums.add_tag_to_album(%{album_id: emery.id, tag_id: tag_2005.id, user_id: carl.id})
Albums.add_tag_to_album(%{album_id: treos.id, tag_id: tag_2005.id, user_id: carl.id})

# ====== create test list ======
{:ok, seed_list} = Lists.create_list(%{permalink: Ecto.UUID.generate(), title: "Test List", user_id: carl.id, private: false})

# ====== associate test albums with test list ======
Lists.add_album_to_list(%{album_id: emery.id, list_id: seed_list.id, user_id: carl.id})
Lists.add_album_to_list(%{album_id: treos.id, list_id: seed_list.id, user_id: carl.id})

# ====== create test album connections ======
Albums.create_album_connection(%{parent_album: emery.id, child_album: treos.id, user_id: carl.id})
Albums.create_album_connection(%{parent_album: treos.id, child_album: artifex_pereo.id, user_id: carl.id})
