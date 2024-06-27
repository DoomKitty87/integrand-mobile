import 'package:flutter/material.dart';
import 'package:integrand/consts.dart';
import 'package:integrand/gradebook.dart';

class Intake extends StatefulWidget {
  const Intake({super.key});

  @override
  State<Intake> createState() => _IntakeCredentials();
}

class _IntakePrimary extends State<Intake> {
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
                        // Move to credentials intake
                      },
                  child: const Text(
                    "Get Started",
                    style: bodyStyle,
                  )),
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

class _IntakeCredentials extends State<Intake> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: Column(
        children: [
          const SizedBox(
            height: 100.0,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 30.0, right: 30.0),
            child: AddInformationTitle(),
          ),
          const SizedBox(
            height: 50.0,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 30.0, right: 30.0),
            child: CredentialsDescription(),
          ),
          const SizedBox(
            height: 50.0,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 30.0, right: 30.0),
            child: CredentialsForm(),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 30.0, right: 30.0, bottom: 30.0),
                child: TextButton(
                    style: buttonStyle,
                    onPressed: () => {
                          // Submit credentials form
                        },
                    child: const Text(
                      "Continue",
                      style: bodyStyle,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddInformationTitle extends StatelessWidget {
  const AddInformationTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
      children: <TextSpan>[
        const TextSpan(
          text: "Add ",
          style: titleStyle,
        ),
        TextSpan(
          text: "School",
          style: titleStyleWithGradient,
        ),
        const TextSpan(
          text: " Information",
          style: titleStyle,
        ),
      ],
    ));
  }
}

class CredentialsDescription extends StatelessWidget {
  const CredentialsDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Integrand uses your information to access StudentVUE and Canvas to show you your grades and upcoming assignments.",
      style: bodyStyle,
    );
  }
}

class CredentialsForm extends StatelessWidget {
  const CredentialsForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: "Username",
            labelStyle: bodyStyleSubdued,
          ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        TextField(
          decoration: InputDecoration(
            labelText: "Password",
            labelStyle: bodyStyleSubdued,
          ),
        ),
        const SizedBox(
          height: 20.0,
        ),
      ],
    );
  }
}
