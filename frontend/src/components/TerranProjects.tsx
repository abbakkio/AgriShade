import React from "react";
import Image from "next/image";

interface ProjectItem {
  id: number;
  image: string;
  title: string;
  date: string;
}

const projectsList: ProjectItem[] = [
  {
    id: 1,
    image: "/assets/terran/SAF4RxUG43TRENcqpLiuNzBvu74.jpeg",
    title: "Renewable Energy Transition Across Multiple Retail Locations",
    date: "Jan 11, 2026",
  },
  {
    id: 2,
    image: "/assets/terran/OBww121K7TtHrQw0PGiAnkGO1o8.jpeg",
    title: "38% Chemical Reduction for a Regional Manufacturing Business",
    date: "Jan 11, 2026",
  },
  {
    id: 3,
    image: "/assets/terran/tCm9GM8YlVrK0MpchN9wHyNQs8.jpeg",
    title: "Full Environmental Compliance for a Growing Food & Beverage Brand",
    date: "Jan 11, 2026",
  },
  {
    id: 4,
    image: "/assets/terran/GYQI3k7e1zX4Mky2ozIgTX3zE.jpeg",
    title: "Launching a Sustainability-First Platform with B-Corp Alignment",
    date: "Jan 11, 2026",
  },
];

export default function TerranProjects() {
  return (
    <section className="py-28 bg-white border-t border-[#070d0c]/10" id="projects">
      <div className="max-w-[1200px] mx-auto px-6">
        
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4 mb-14">
          <h2 className="text-[38px] sm:text-[54px] font-normal tracking-[-0.03em] text-[#070d0c] leading-[1.05]">
            Our work in the field
          </h2>
          <a
            href="https://github.com/abbakkio/AgriShade"
            target="_blank"
            rel="noopener noreferrer"
            className="text-[15px] font-medium text-[#070d0c] hover:text-pine-900 flex items-center gap-2 group"
          >
            <span>Explore all projects</span>
            <span className="transition-transform group-hover:translate-x-1">→</span>
          </a>
        </div>

        {/* 2x2 or 4-Card Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {projectsList.map((project) => (
            <article
              key={project.id}
              className="flex flex-col group cursor-pointer"
            >
              <div className="relative w-full h-[320px] sm:h-[380px] rounded-[24px] overflow-hidden bg-slate-100 mb-5 shadow-sm">
                <Image
                  src={project.image}
                  alt={project.title}
                  fill
                  className="object-cover transition-transform duration-500 group-hover:scale-105"
                  sizes="(max-width: 768px) 100vw, 580px"
                />
              </div>

              <div className="flex items-center justify-between gap-4">
                <div className="flex flex-col">
                  <h3 className="text-[20px] sm:text-[22px] font-normal text-[#070d0c] group-hover:text-pine-900 transition-colors leading-snug">
                    {project.title}
                  </h3>
                  <span className="text-[13px] text-[#070d0c]/50 mt-1">
                    {project.date}
                  </span>
                </div>

                <span className="text-[14px] font-medium text-[#070d0c] group-hover:text-pine-900 shrink-0 flex items-center gap-1">
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
