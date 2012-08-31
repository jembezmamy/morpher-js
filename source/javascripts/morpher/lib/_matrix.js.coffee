class MorpherJS.Matrix
  values: false
  transforms: false
  
  constructor: ->
    @values = [1,0,0,0,1,0,0,0,1]
    for i, val of arguments
      @values[i] = val
    @transforms = []

  get: (i, j) =>
    @values[i*3+j]

  set: (i, j, value) =>
    @values[i*3+j] = value
    

  translate: (tx = 0, ty = 0) =>
    @transforms.unshift new MorpherJS.Matrix(1,0,tx,0,1,ty,0,0,1)

  scale: (sx = 1, sy = 1) =>
    @transforms.unshift new MorpherJS.Matrix(sx,0,0,0,sy,0,0,0,1)

  skew: (sx = 0, sy = 0) =>
    @transforms.unshift new MorpherJS.Matrix(1,Math.tan(sx),0,Math.tan(sy),1,0,0,0,1)

  rotate: (a) =>
    @transforms.unshift new MorpherJS.Matrix(Math.cos(a),-Math.sin(a),0,Math.sin(a),Math.cos(a),0,0,0,1)

  shear: (sx = 0, sy = 0) =>
    @transforms.unshift new MorpherJS.Matrix(1,sx,0,sy,1,0,0,0,1)

  removeTransform: (i) =>
    @transforms.splice(@transforms.length-1-i, 1)

  apply: =>
    matr = new MorpherJS.Matrix()
    for transform in @transforms
      matr.multiplyWith(transform)
    matr


  toCSS: =>
    "matrix(#{[@get(0,0), @get(1,0), @get(0,1), @get(1,1), @get(0,2), @get(1,2)].join(', ')})"
    

  multiplyWith: (matrix) =>
    values = []
    for i in [0..2]
      for j in [0..2]
        sum = 0      
        for k in [0..2]
          sum += @get(i,k)*matrix.get(k,j)
        values.push sum
    @values = values
    this
    
