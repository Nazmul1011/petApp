import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:petapp/modules/pet_profile/models/pet_model.dart';
import 'package:petapp/shared/widgets/app_asset_image.dart';

/// Circular pet avatar that shows the uploaded pet image when available and
/// falls back to the default dog/cat asset when [imageUrl] is missing or fails.
class PetAvatar extends StatelessWidget {
  final String? imageUrl;
  final PetType type;
  final double size;
  final BoxFit fit;

  const PetAvatar({
    super.key,
    required this.imageUrl,
    required this.type,
    required this.size,
    this.fit = BoxFit.cover,
  });

  String get _fallbackAsset => type == PetType.CAT
      ? 'assets/images/cat image.webp'
      : 'assets/images/dog image.webp';

  @override
  Widget build(BuildContext context) {
    final url = PetModel.buildPetImageUrl(imageUrl);
    final isNetwork = url.startsWith('http://') || url.startsWith('https://');

    final Widget image = isNetwork
        ? CachedNetworkImage(
            imageUrl: url,
            width: size,
            height: size,
            fit: fit,
            placeholder: (context, url) => _buildFallback(),
            errorWidget: (context, url, error) => _buildFallback(),
          )
        : url.startsWith('assets/')
            ? AppAssetImage(url, width: size, height: size, fit: fit)
            : _buildFallback();

    return ClipOval(
      child: SizedBox(width: size, height: size, child: image),
    );
  }

  Widget _buildFallback() {
    return AppAssetImage(
      _fallbackAsset,
      width: size,
      height: size,
      fit: fit,
    );
  }
}
