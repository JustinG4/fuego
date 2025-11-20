interface PlaceholderImageProps {
  width?: number
  height?: number
  text?: string
  className?: string
  gradient?: string
}

const PlaceholderImage = ({ 
  width = 400, 
  height = 400, 
  text = "Image", 
  className = "",
  gradient = "from-gray-700 to-gray-800"
}: PlaceholderImageProps) => {
  return (
    <div 
      className={`bg-gradient-to-br ${gradient} flex items-center justify-center text-white font-medium ${className}`}
      style={{ width, height }}
    >
      {text}
    </div>
  )
}

export default PlaceholderImage