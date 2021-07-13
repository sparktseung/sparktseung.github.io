function hfun_bar(vname)
  val = Meta.parse(vname[1])
  return round(sqrt(val), digits=2)
end

function hfun_m1fill(vname)
  var = vname[1]
  return pagevar("index", var)
end


function hfun_recentblogposts(m::Vector{String})
  # list = readdir("pages")
  # filter!(f -> endswith(f, ".md"), list)
  # dates = [stat(joinpath("pages", f)).mtime for f in list]
  # perm = sortperm(dates, rev=true)
  # idxs = perm[1:min(2, length(perm))]
  # io = IOBuffer()
  # write(io, "<ul>")
  # for (k, i) in enumerate(idxs)
  #     fi = "/pages/" * splitext(list[i])[1] * "/"
  #     ptitle = pagevar(fi, :title)
  #     write(io, """<li><a href="$fi">"$ptitle"</a></li>\n""")
  # end
  # write(io, "</ul>")
  # return String(take!(io))

  @assert length(m) == 1 "only one argument allowed for recent posts (the number of recent posts to pull)"
  n = parse(Int64, m[1])
  list = readdir("pages")
  filter!(f -> endswith(f, ".md") && f != "index.md" , list)
  # markdown = ""
  io = IOBuffer()
  write(io, "<ul>")
  posts = []
  df = DateFormat("mm/dd/yyyy")
  for (k, post) in enumerate(list)
      fi = "pages/" * splitext(post)[1]
      title = pagevar(fi, :title)
      datestr = pagevar(fi, :date)
      # date = Date(pagevar(fi, :date), df)
      push!(posts, (title=title, link=fi, date=datestr))
  end

  # pull all posts if n <= 0
  n = n >= 0 ? n : length(posts)+1

  for ele in sort(posts, by=x->x.date, rev=true)[1:min(length(posts), n)]
    # markdown *= "* [($(ele.date)) $(ele.title)](../$(ele.link))\n"
    write(io, """<li><a href="$(ele.link)"> ($(ele.date)) $(ele.title)</a></li>\n""")
  end

  # return fd2html(markdown, internal=true, nop=false)
  write(io, "</ul>")
  return String(take!(io))

end

function lx_baz(com, _)
  # keep this first line
  brace_content = Franklin.content(com.braces[1]) # input string
  # do whatever you want here
  return uppercase(brace_content)
end

