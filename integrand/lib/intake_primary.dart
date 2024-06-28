import 'package:flutter/material.dart';
import 'package:integrand/consts.dart';
import 'package:integrand/helpers/page_animation.dart';
import 'package:integrand/intake_credentials.dart';

class IntakePrimary extends StatefulWidget {
  const IntakePrimary({super.key});

  @override
  State<IntakePrimary> createState() => _IntakePrimary();
}

class _IntakePrimary extends State<IntakePrimary> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 100.0,
        ),
        const Padding(
            padding: EdgeInsets.only(left: 30.0, right: 30.0),
            child: WelcomeText()),
        const SizedBox(
          height: 50.0,
        ),
        const Padding(
          padding: EdgeInsets.only(left: 30.0, right: 30.0),
          child: DescriptionText(),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 30.0),
              child: TextButton(
                style: buttonStyle,
                onPressed: () => {
                  animateWithSlideFromRight(context, IntakeCredentials(), Durations.medium2)
                },
                child: const Text(
                  "Get Started",
                  style: bodyStyle,
                )
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
      children: <TextSpan>[
        const TextSpan(
          text: "Welcome to ",
          style: titleStyle,
        ),
        TextSpan(
          text: appName,
          style: titleStyleWithGradient,
        ),
      ],
    ));
  }
}

class DescriptionText extends StatelessWidget {
  const DescriptionText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Integrand is your main point of access for all things school related.\n\nIntegrand uses data from StudentVUE, Canvas, and your school staff to provide you with an accessible overview of your classes, grades, and resources, all within a single app.",
      style: bodyStyle,
    );
  }
}