# Video Specifications for DroneVista Services

## General Video Requirements

### Technical Specifications:
- **Format**: MP4 (H.264 codec)
- **Resolution**: 1920x1080 (Full HD) or 3840x2160 (4K)
- **Frame Rate**: 30fps or 60fps
- **Bitrate**: 8-15 Mbps for Full HD, 20-35 Mbps for 4K
- **Audio**: Not required (videos will be muted on website)
- **Duration**: 15-30 seconds (will loop continuously)

### Optimization Settings:
- **Codec**: H.264 (best compatibility)
- **Profile**: High Profile
- **Level**: 4.0 or 4.1
- **Encoding**: Variable Bitrate (VBR) 2-pass
- **Web Optimization**: Enable "Fast Start" (moov atom at beginning)

## Video Specifications by Service

### 1. Mountain Filming (montana-bg.mp4)
- **Content**: Aerial shots of mountains, peaks, hiking trails, sunrise/sunset over mountains
- **Style**: Smooth, sweeping drone movements
- **Color Grading**: Natural with enhanced contrast, golden hour preferred
- **Duration**: 20-30 seconds
- **Key Shots**: 
  - Wide mountain panoramas
  - Flying over ridges
  - Revealing mountain peaks through clouds
  - Following hiking trails from above

### 2. Beach Filming (playa-bg.mp4)
- **Content**: Coastal views, waves, beaches from above, surfers/beachgoers
- **Style**: Dynamic movements following coastline
- **Color Grading**: Vibrant blues and warm sand tones
- **Duration**: 15-25 seconds
- **Key Shots**:
  - Top-down view of waves breaking
  - Following the coastline
  - Sunrise/sunset over ocean
  - Beach activities from above

### 3. Audiovisual Production (produccion-bg.mp4)
- **Content**: Behind-the-scenes of drone operations, equipment shots, professional setups
- **Style**: Mix of drone footage and ground shots
- **Color Grading**: Professional, slightly desaturated
- **Duration**: 20-30 seconds
- **Key Shots**:
  - Drone taking off/landing
  - Operator controlling drone
  - Multiple angles of drone in flight
  - Montage of different location types

### 4. Corporate Services (corporativo-bg.mp4)
- **Content**: City skylines, office buildings, corporate events, construction sites
- **Style**: Steady, professional movements
- **Color Grading**: Clean, corporate feel with blue/gray tones
- **Duration**: 20-30 seconds
- **Key Shots**:
  - Orbiting tall buildings
  - Flying over business districts
  - Corporate campus overviews
  - Event coverage from above

### 5. 3D Telemetry (telemetria-bg.mp4)
- **Content**: Technical footage showing 3D scanning process, point clouds, architectural details
- **Style**: Precise, technical movements
- **Color Grading**: High-tech feel with blue/cyan accents
- **Duration**: 15-25 seconds
- **Key Shots**:
  - Systematic scanning patterns
  - Close-ups of architectural details
  - Overlay graphics showing 3D data
  - Before/after comparisons

## FFmpeg Commands for Optimization

### For Full HD (1080p) videos:
```bash
ffmpeg -i input.mp4 -c:v libx264 -preset slow -crf 22 -profile:v high -level 4.1 -pix_fmt yuv420p -movflags +faststart -an output.mp4
```

### For 4K videos (downsample to Full HD for web):
```bash
ffmpeg -i input_4k.mp4 -vf scale=1920:1080 -c:v libx264 -preset slow -crf 22 -profile:v high -level 4.1 -pix_fmt yuv420p -movflags +faststart -an output.mp4
```

### For maximum compatibility:
```bash
ffmpeg -i input.mp4 -c:v libx264 -preset slow -crf 23 -profile:v baseline -level 3.0 -pix_fmt yuv420p -movflags +faststart -maxrate 8M -bufsize 8M -an output.mp4
```

## Directory Structure

Create the following structure in your project:
```
SitioWebDrone/
├── videos/
│   ├── montana-bg.mp4
│   ├── playa-bg.mp4
│   ├── produccion-bg.mp4
│   ├── corporativo-bg.mp4
│   └── telemetria-bg.mp4
├── img/
│   ├── montana-poster.jpg
│   ├── playa-poster.jpg
│   ├── produccion-poster.jpg
│   ├── corporativo-poster.jpg
│   └── telemetria-poster.jpg
```

## Creating Poster Images

Extract a frame from each video for the poster:
```bash
ffmpeg -i montana-bg.mp4 -vf "select=eq(n\,0)" -vframes 1 montana-poster.jpg
```

Or at a specific time (e.g., 5 seconds):
```bash
ffmpeg -i montana-bg.mp4 -ss 00:00:05 -vframes 1 montana-poster.jpg
```

## Tips for Best Results

1. **File Size**: Keep videos under 30MB for fast loading
2. **Loop Points**: Ensure smooth transition from end to beginning
3. **Movement**: Avoid too fast movements that might distract from content
4. **Contrast**: Ensure text remains readable over all parts of the video
5. **Testing**: Test on mobile devices and slower connections
