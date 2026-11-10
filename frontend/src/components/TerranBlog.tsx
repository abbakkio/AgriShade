import React from "react";
import Image from "next/image";

interface BlogPost {
  id: number;
  image: string;
  title: string;
  date: string;
}

const blogPosts: BlogPost[] = [
  {
    id: 1,
    image: "/assets/terran/JEOTupLCK3a4FmrD5kMIeyUU67g.jpeg",
    title: "Carbon Reporting 101: What Small Businesses Actually Need to Know",
    date: "Jan 11, 2026",
  },
  {
    id: 2,
    image: "/assets/terran/BJUyRvkfPn00aw6sl9gerZgLljs.jpeg",
    title: "Why Sustainability Is Your Strongest Business Differentiator",
    date: "Jan 11, 2026",
  },
  {
    id: 3,
    image: "/assets/terran/Hu4bgKYd251XMxGfqFaZaNijVQ.jpeg",
    title: "How Local Farms Can Make the Switch to Edge AI in 2026",
    date: "Jan 11, 2026",
  },
];

export default function TerranBlog() {
  return (
    <section className="py-28 bg-white border-t border-[#070d0c]/10" id="blog">
      <div className="max-w-[1200px] mx-auto px-6">
        
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4 mb-14">
          <h2 className="text-[38px] sm:text-[54px] font-normal tracking-[-0.03em] text-[#070d0c] leading-[1.05]">
            Insights from the field
          </h2>
          <a
            href="#blog"
            className="text-[15px] font-medium text-[#070d0c] hover:text-pine-900 flex items-center gap-2 group"
          >
            <span>Explore all blogs</span>
            <span className="transition-transform group-hover:translate-x-1">→</span>
          </a>
        </div>

        {/* 3-Card Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {blogPosts.map((post) => (
            <article key={post.id} className="flex flex-col group cursor-pointer">
              <div className="relative w-full h-[260px] rounded-[22px] overflow-hidden bg-slate-100 mb-5 shadow-sm">
                <Image
                  src={post.image}
                  alt={post.title}
                  fill
                  className="object-cover transition-transform duration-500 group-hover:scale-105"
                  sizes="(max-width: 768px) 100vw, 380px"
                />
              </div>

              <div className="flex flex-col justify-between flex-1">
                <div>
                  <span className="text-[13px] text-[#070d0c]/50 mb-1.5 block">
                    {post.date}
                  </span>
                  <h3 className="text-[19px] font-normal text-[#070d0c] group-hover:text-pine-900 transition-colors leading-snug mb-4">
                    {post.title}
                  </h3>
                </div>

                <span className="text-[14px] font-medium text-[#070d0c] group-hover:text-pine-900 flex items-center gap-1">
                  Read <span className="transition-transform group-hover:translate-x-1">→</span>
                </span>
              </div>
            </article>
          ))}
        </div>

      </div>
    </section>
  );
}
