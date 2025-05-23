// Copyright 2025 International Digital Economy Academy
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
extern "js" fn get_relative_time(date : String) -> String =
  #|function getRelativeTime(dateString) {
  #|  const date = new Date(dateString);
  #|  const now = new Date();
  #|  const diff = now - date;
  #|  const rtf = new Intl.RelativeTimeFormat("en", { numeric: "auto" });
  #|  const seconds = Math.floor(diff / 1000);
  #|  const minutes = Math.floor(seconds / 60);
  #|  const hours = Math.floor(minutes / 60);
  #|  const days = Math.floor(hours / 24);
  #|  const months = Math.floor(days / 30);
  #|  const years = Math.floor(days / 365);
  #|  if (years > 0) return rtf.format(-years, "year");
  #|  if (months > 0) return rtf.format(-months, "month");
  #|  if (days > 0) return rtf.format(-days, "day");
  #|  if (hours > 0) return rtf.format(-hours, "hour");
  #|  if (minutes > 0) return rtf.format(-minutes, "minute");
  #|  return rtf.format(-seconds, "second");
  #|}

///|
fn simple_module_card(mod : ModuleIndex) -> Html[Msg] {
  a(
    class="select-none p-4 h-50 flex bg-white outline outline-transparent flex-col border-gray-200 border-b lg:hover:outline-mooncake2 lg:hover:border-transparent lg:hover:shadow-md lg:border lg:rounded-md lg:min-h-28 lg:overflow-ellipsis transition-all",
    href="/docs/\{mod.path}",
    [
      div(class="flex flex-row text-lg font-semibold", [
        span(class="text-gray-500", [text(mod.author)]),
        span(class="px-1 text-gray-300", [text("/")]),
        span([text(mod.name)]),
      ]),
      div(
        class="pt-2 text-gray-500 flex-grow flex flex-col justify-between gap-2",
        [
          p(class="text-sm", [text(mod.description.or(""))]),
          p(class="text-[0.8rem] w-full text-right", [
            text(mod.created_at.map(get_relative_time).or("")),
          ]),
        ],
      ),
    ],
  )
}

///|
fn module_card(mod : ModuleIndex) -> Html[Msg] {
  let keywords = match mod.keywords {
    None => nothing()
    Some(keywords) =>
      div(
        class="flex gap-2 h-8 flex-wrap overflow-y-hidden shrink-0",
        keywords.map(fn {
          keyword =>
            span(
              class="text-sm/4 h-5 bg-gray-50 text-gray-600 px-2 my-2 border-gray-200  border rounded",
              [text(keyword)],
            )
        }),
      )
  }
  let description = match mod.description {
    None => div(class="flex-grow", [])
    Some(description) =>
      p(class="text-gray-700 py-3 overflow-ellipsis grow text-sm", [
        text(description),
      ])
  }
  let time = match mod.created_at {
    Some(t) => p([text(get_relative_time(t))])
    None => nothing()
  }
  a(
    class="select-none p-4 min-h-32 flex flex-col border-t bg-white hover:bg-gray-100 transition-all",
    href="/docs/\{mod.path}",
    [
      div(class="flex flex-row text-lg font-semibold", [
        h2(class="text-gray-500", [text(mod.author)]),
        h2(class="px-1 text-gray-300", [text("/")]),
        h2(class="", [text(mod.name)]),
      ]),
      description,
      div(class="flex justify-between items-center text-gray-600 text-sm", [
        keywords, time,
      ]),
    ],
  )
}

///|
fn recently_updated(recently : Array[ModuleIndex]) -> Html[Msg] {
  let recently_updated = recently.map(simple_module_card)
  div([
    div(class="container lg:w-2/3 px-4", [
      h1(class="border-b p-4 text-sm font-bold text-gray-400 lg:border-0", [
        text("RECENTLY UPDATED"),
      ]),
      div(
        class="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-4",
        recently_updated,
      ),
    ]),
  ])
}

///|
fn all_modules(modules : Map[Char, Array[ModuleIndex]]) -> Html[Msg] {
  let all_modules = modules
    .iter2()
    .to_array()
    ..sort_by(fn(a, b) { a.0.to_int() - b.0.to_int() })
    .map(fn(x) {
      let (key, value) = x
      let modules = value.map(simple_module_card)
      div(class="pt-2", [
        div(class="container lg:w-2/3 px-4", [
          h1(class="border-b p-4 text-sm font-bold text-gray-400 lg:border-0", [
            text(key.to_string()),
          ]),
          div(
            class="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-4",
            modules,
          ),
        ]),
      ])
    })
  div(class="pt-10", [
    div(class="container lg:w-2/3 px-4", [
      h1(class="border-b p-4 text-sm font-bold text-gray-400 lg:border-0", [
        text("ALL MODULES"),
      ]),
    ]),
    div(all_modules),
  ])
}

///|
fn search_result(mods : Array[ModuleIndex]) -> Html[Msg] {
  let module_cards = mods.map(module_card)
  div([
    div(class="container lg:w-3/5 px-4", [
      h1(class="p-4 text-sm font-bold text-gray-400 lg:border-0", [
        text("SEARCH RESULT"),
      ]),
      div(class="grid grid-cols-1", module_cards),
    ]),
  ])
}

///|
fn navbar() -> Html[Msg] {
  div(class="w-full flex justify-center", [
    div(
      class="min-h-14 w-4/5 flex flex-col sm:flex-row justify-between items-center",
      [
        div(class="font-title select-none p-4", [
          // use whitespace-nowrap to prevent logo from wrapping
          h1(class="whitespace-nowrap text-gray-700 font-semibold", [
            text("🥮 mooncakes.io (Community Edition)"),
          ]),
        ]),
        div(class="justify-center my-2 w-full max-w-72 shadow-sm", [
          input(
            input_type=Text,
            placeholder="Search modules ...",
            class="border rounded-full px-4 w-full py-2 bg-zinc-50 focus:border-mooncake2 outline-none transition-colors",
            input=FilterChanged(_),
          ),
        ]),
        div(class="text-gray-700 font-semibold invisible", [
          a(href="", [text("Browse All Module")]),
        ]),
      ],
    ),
  ])
}
