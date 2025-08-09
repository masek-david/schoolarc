import 'package:m3_expressive_shapes/shapes/material_shapes.dart';

final symetricShapes = MaterialShapes.values
    .where(
      (element) =>
          element != MaterialShapes.circle &&
          element != MaterialShapes.pentagon &&
          element != MaterialShapes.slanted &&
          element != MaterialShapes.arch &&
          element != MaterialShapes.fan &&
          element != MaterialShapes.arrow &&
          element != MaterialShapes.semiCircle &&
          element != MaterialShapes.oval &&
          element != MaterialShapes.pill &&
          element != MaterialShapes.triangle &&
          element != MaterialShapes.diamond &&
          element != MaterialShapes.clamShell &&
          element != MaterialShapes.gem &&
          element != MaterialShapes.ghostish &&
          element != MaterialShapes.boom &&
          element != MaterialShapes.puffy &&
          element != MaterialShapes.puffyDiamond &&
          element != MaterialShapes.pixelTriangle &&
          element != MaterialShapes.bun &&
          element != MaterialShapes.heart,
    )
    .toList();

final textShapes = MaterialShapes.values
    .where(
      (element) =>
          element != MaterialShapes.arrow &&
          element != MaterialShapes.circle &&
          element != MaterialShapes.semiCircle &&
          element != MaterialShapes.oval &&
          element != MaterialShapes.triangle &&
          element != MaterialShapes.diamond &&
          element != MaterialShapes.pixelTriangle &&
          element != MaterialShapes.boom &&
          element != MaterialShapes.bun &&
          element != MaterialShapes.heart,
    )
    .toList();
