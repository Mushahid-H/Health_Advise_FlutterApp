// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health_advisor/Models/MedicationReminder.dart';
import 'package:health_advisor/Screens/MedicationReminderDisplayScreen.dart';
import 'package:health_advisor/Screens/MedicationReminderScreen.dart';
import 'package:health_advisor/Screens/bmi_screen.dart';
import 'package:health_advisor/Screens/first_aid_detail_screen.dart';
import 'package:health_advisor/Screens/first_aid_screen.dart';
import 'package:health_advisor/Screens/forgot_password_page.dart';
import 'package:health_advisor/Screens/login_page.dart';
import 'package:health_advisor/Screens/register_page.dart';
// import 'dart:math';
import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

import 'package:health_advisor/Screens/splash_screen.dart';
import 'package:health_advisor/firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  tz.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: null, macOS: null);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthCare App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => SymptomsScreen(),
        '/bmi': (context) => BMIScreen(),
        '/first_aid': (context) => FirstAidScreen(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        '/medication-reminder': (context) => MedicationReminderScreen(),
        'reminder-display': (context) => MedicationReminderDisplayScreen()
      },
    );
  }
}

class SymptomsScreen extends StatefulWidget {
  @override
  _SymptomsScreenState createState() => _SymptomsScreenState();
}

class _SymptomsScreenState extends State<SymptomsScreen> {
  TextEditingController _symptomsController = TextEditingController();
  List<String> _suggestedDiseases = [];
  Map<String, List<String>> _suggestedMedications = {};
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Health Advisor',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgrnd.jpeg'),
            fit: BoxFit.fill,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome, ${user!.displayName}!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _symptomsController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Symptoms',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _suggestedDiseases = [];
                      _suggestedMedications = {};
                    });
                    final String symptoms = _symptomsController.text;
                    if (symptoms.isEmpty) return;
                    // Simulate fetching data from OpenAI API
                    await Future.delayed(Duration(seconds: 2));
                    setState(() {
                      _suggestedDiseases = _suggestDiseases(symptoms);
                      _suggestedMedications =
                          _suggestMedications(_suggestedDiseases);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Get Medical Suggestions'),
                ),
                const SizedBox(height: 16.0),
                if (_suggestedDiseases.isNotEmpty || counter++ == 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Suggested Diseases:',
                        style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo),
                      ),
                      Wrap(
                        spacing: 8.0,
                        children: _suggestedDiseases
                            .map(
                              (disease) => Chip(
                                label: Text(disease,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    )),
                                backgroundColor: Colors.blue,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16.0),
                      if (_suggestedMedications.isNotEmpty || counter++ == 1)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Suggested Medications:',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _suggestedMedications.entries
                                  .map(
                                    (entry) => Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${entry.key}:",
                                          style: const TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo),
                                        ),
                                        Text(
                                          entry.value.join(", "),
                                          style: const TextStyle(
                                              fontSize: 13.0,
                                              color: Colors.indigo),
                                        ),
                                        const SizedBox(height: 8.0),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 10.0),
                          ],
                        )
                      else
                        const Text(
                          'No matching medications found.',
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.indigo),
                        ),
                    ],
                  )
                else
                  const Text(
                    'No matching diseases found. Please try again.',
                    style: TextStyle(fontSize: 18.0, color: Colors.indigo),
                  ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/bmi');
                  },
                  child: Text('Calculate BMI'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/first_aid');
                  },
                  child: Text('First Aid Guide'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/medication-reminder');
                  },
                  child: Text('Set Medication Reminder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _suggestDiseases(String symptoms) {
    symptoms = symptoms.toLowerCase();
    List<String> suggestedDiseases = [];

    for (String symptom in symptomDiseaseMapping.keys) {
      if (symptom.toLowerCase().contains(symptoms)) {
        suggestedDiseases.addAll(symptomDiseaseMapping[symptom]!);
      }
    }

    // Remove duplicate diseases
    return suggestedDiseases.toSet().toList();
  }

  Map<String, List<String>> _suggestMedications(List<String> diseases) {
    Map<String, List<String>> medications = {};

    for (String disease in diseases) {
      List<String> associatedMedications =
          medicationRecommendation[disease] != null
              ? [medicationRecommendation[disease]!['Medication']!]
              : [];
      medications[disease] = associatedMedications;
    }

    return medications;
  }
}

class FirstAidItem extends StatelessWidget {
  final String title;
  final String description;

  const FirstAidItem({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FirstAidDetailScreen(
              title: title,
              description: description,
            ),
          ),
        );
      },
      child: Card(
        color: Colors.blue.withOpacity(0.8),
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 8.0),
              // Text(
              //   description,
              //   style: const TextStyle(fontSize: 16.0, color: Colors.white),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

// Your symptomDiseaseMapping and medicationRecommendation maps go here

Map<String, Map<String, String>> medicationRecommendation = {
  'Migraine': {'Medication': 'Triptans (e.g., sumatriptan), NSAIDs'},
  'Tension Headache': {
    'Medication':
        'Over-the-counter pain relievers (e.g., acetaminophen, ibuprofen)'
  },
  'Flu': {'Medication': 'Antiviral medications (e.g., oseltamivir)'},
  'High Blood Pressure': {
    'Medication':
        'Antihypertensive medications (e.g., ACE inhibitors, beta-blockers)'
  },
  'Dizziness': {
    'Medication': 'Antivertigo medications (e.g., meclizine), physical therapy'
  },
  'Dehydration': {'Medication': 'Rehydration solutions'},
  'Anxiety': {'Medication': 'Anxiolytics (e.g., lorazepam)'},
  'Chronic Fatigue': {
    'Medication': 'Symptomatic treatment, lifestyle modifications'
  },
  'Depression': {'Medication': 'Antidepressants (e.g., SSRIs, SNRIs)'},
  'Type 2 Diabetes': {
    'Medication': 'Oral antidiabetic medications (e.g., metformin), insulin'
  },
  'Thyroid Problems': {
    'Medication': 'Thyroid hormone replacement (e.g., levothyroxine)'
  },
  'Kidney Disease': {
    'Medication': 'Management of underlying causes, supportive care'
  },
  'Heart Disease': {'Medication': 'Nitroglycerin, beta-blockers, aspirin'},
  'COPD': {'Medication': 'Bronchodilators, inhaled corticosteroids'},
  'Asthma': {'Medication': 'Inhaled corticosteroids, bronchodilators'},
  'Stomach Flu': {
    'Medication': 'Symptomatic relief, antiemetics, rehydration solutions'
  },
  'Arthritis': {'Medication': 'NSAIDs, DMARDs, corticosteroids'},
  'Alzheimer\'s': {
    'Medication': 'Cholinesterase inhibitors (e.g., donepezil), memantine'
  },
  'Underactive Thyroid': {
    'Medication': 'Levothyroxine (thyroid hormone replacement)'
  },
  'Muscle Strain': {
    'Medication': 'Rest, Pain relievers (e.g., acetaminophen, ibuprofen)'
  },
  'Slipped Disc': {
    'Medication':
        'Physical therapy, Muscle relaxants, Pain relievers (e.g., ibuprofen)'
  },
  'Concussion': {'Medication': 'Rest, Pain relievers (e.g., acetaminophen)'},
  'Amnesia': {'Medication': 'No specific medication'},
  'Stomach Inflammation': {
    'Medication':
        'Antacids, Proton pump inhibitors (e.g., omeprazole), H2 blockers (e.g., ranitidine)'
  },
  'Appendicitis': {'Medication': 'Surgery (Appendectomy)'},
  'Unknown': {
    'Medication': 'No specific medication recommendation for this disease'
  },
  'Insomnia': {'Medication': 'Sleep hygiene, Cognitive behavioral therapy'},
  'Bipolar Disorder': {'Medication': 'Mood stabilizers (e.g., lithium)'},
  'Fainting': {'Medication': 'Depends on underlying cause'},
  'Epilepsy': {'Medication': 'Antiepileptic drugs (e.g., carbamazepine)'},
  'Nerve Pain': {
    'Medication': 'Pain relievers, Antidepressants, Antiseizure medications'
  },
  'Glaucoma': {'Medication': 'Eyedrops (e.g., prostaglandins)'},
  'IBS': {'Medication': 'Dietary changes, Antispasmodic medications'},
  'Difficulty Swallowing': {'Medication': 'Treatment of underlying cause'},
  'Eczema': {'Medication': 'Topical corticosteroids, Moisturizers'},
  'Diabetes Insipidus': {'Medication': 'Desmopressin, Thiazide diuretics'},
  'ADHD': {
    'Medication':
        'Stimulants (e.g., methylphenidate), Non-stimulants (e.g., atomoxetine)'
  },
  'Common Cold': {
    'Medication': 'Rest, Hydration, Over-the-counter cold remedies'
  },
  'Strep Throat': {
    'Medication':
        'Antibiotics (e.g., penicillin), Pain relievers (e.g., acetaminophen)'
  },
  'Acne': {'Medication': 'Topical retinoids, Benzoyl peroxide, Antibiotics'},
  'Anemia': {'Medication': 'Iron supplements, Vitamin B12, Folic acid'},
  'Bronchitis': {'Medication': 'Bronchodilators, Cough suppressants'},
  'Chickenpox': {'Medication': 'Antihistamines, Antiviral medications'},
  'Gout': {'Medication': 'NSAIDs, Colchicine, Corticosteroids'},
  'Hepatitis': {'Medication': 'Antiviral medications, Interferons'},
  'High Cholesterol': {'Medication': 'Statins, Lifestyle changes'},
  'Low Sodium': {'Medication': 'Sodium supplements, Fluid restriction'},
  'Liver Disease': {
    'Medication':
        'Depends on the specific condition, e.g., antiviral medications for hepatitis'
  },
  'Multiple Sclerosis': {
    'Medication': 'Immunomodulatory drugs, Corticosteroids'
  },
  'Osteoporosis': {
    'Medication': 'Bisphosphonates, Calcium and Vitamin D supplements'
  },
  'Pneumonia': {'Medication': 'Antibiotics, Antivirals, Supportive care'},
  'Psoriasis': {'Medication': 'Topical corticosteroids, Systemic agents'},
  'Shingles': {'Medication': 'Antiviral medications, Pain relievers'},
  'Sinus Infection': {'Medication': 'Decongestants, Antibiotics if bacterial'},
  'TB': {'Medication': 'Antitubercular drugs'},
  'UTI': {'Medication': 'Antibiotics'},
  'Vitamin D Deficiency': {'Medication': 'Vitamin D supplements'},
  'Yeast Infection': {'Medication': 'Antifungal medications'},
  'Zika Virus': {'Medication': 'Supportive care'},
  'Lyme Disease': {'Medication': 'Antibiotics (e.g., doxycycline)'},
  'Pink Eye': {'Medication': 'Antibiotic eye drops'},
  'Sprained Ankle': {'Medication': 'Rest, Ice, Compression, Elevation'},
  'Food Poisoning': {'Medication': 'Hydration, Antiemetics'},
  'Heat Stroke': {'Medication': 'Cooling measures, Hydration'},
  'Stroke': {'Medication': 'Antithrombotics, Surgery'},
  'Heart Attack': {'Medication': 'Aspirin, Nitroglycerin, Beta-blockers'},
  'Pulmonary Embolism': {'Medication': 'Anticoagulants, Thrombolytics'},
  'Kidney Stones': {'Medication': 'Pain relievers, Alpha-blockers'},
  'Prostate Cancer': {'Medication': 'Hormone therapy, Chemotherapy, Surgery'},
  'Breast Cancer': {'Medication': 'Chemotherapy, Radiation, Surgery'},
  'Lung Cancer': {'Medication': 'Chemotherapy, Radiation, Surgery'},
  'Ovarian Cancer': {'Medication': 'Chemotherapy, Surgery'},
  'Pancreatic Cancer': {'Medication': 'Chemotherapy, Surgery'},
  'Colon Cancer': {'Medication': 'Chemotherapy, Surgery'},
  'Leukemia': {'Medication': 'Chemotherapy, Radiation, Bone marrow transplant'},
  'Lymphoma': {'Medication': 'Chemotherapy, Radiation, Bone marrow transplant'},
  'Melanoma': {'Medication': 'Surgery, Radiation, Immunotherapy'},
  'Parkinson\'s Disease': {'Medication': 'Levodopa, Dopamine agonists'},
  'Alzheimer\'s Disease': {
    'Medication': 'Cholinesterase inhibitors, Memantine'
  },
  'ALS': {'Medication': 'Riluzole, Edaravone'},
  'Huntington\'s Disease': {'Medication': 'Tetrabenazine, Antipsychotics'},
  'Cystic Fibrosis': {
    'Medication': 'Antibiotics, Mucus-thinning drugs, Enzyme supplements'
  },
  'Sickle Cell Disease': {'Medication': 'Hydroxyurea, Blood transfusions'},
  'Hemophilia': {'Medication': 'Clotting factor replacement'},
  'Thalassemia': {'Medication': 'Blood transfusions, Iron chelation therapy'},
  'Crohn\'s Disease': {
    'Medication': 'Anti-inflammatory drugs, Immune system suppressors'
  },
  'Ulcerative Colitis': {
    'Medication': 'Anti-inflammatory drugs, Immune system suppressors'
  },
  'Celiac Disease': {'Medication': 'Gluten-free diet'},
  'Peptic Ulcer Disease': {'Medication': 'Antibiotics, Proton pump inhibitors'},
  'GERD': {'Medication': 'Antacids, H2 blockers, Proton pump inhibitors'},
  'Diverticulitis': {'Medication': 'Antibiotics, Pain relievers'},
  'Hemorrhoids': {'Medication': 'Topical treatments, Fiber supplements'},
  'Pancreatitis': {
    'Medication': 'Pain relievers, Enzyme supplements, IV fluids'
  },
  'Cholecystitis': {'Medication': 'Antibiotics, Pain relievers, Surgery'},
  'Liver Cirrhosis': {
    'Medication': 'Diuretics, Beta-blockers, Liver transplant'
  },
  'Hepatitis B': {'Medication': 'Antiviral drugs, Interferon'},
  'Hepatitis C': {'Medication': 'Antiviral drugs, Interferon'},
  'Hyperthyroidism': {'Medication': 'Antithyroid drugs, Radioactive iodine'},
  'Hypothyroidism': {'Medication': 'Levothyroxine'},
  'Addison\'s Disease': {'Medication': 'Corticosteroids'},
  'Cushing\'s Syndrome': {
    'Medication': 'Surgery, Radiation, Medications to control cortisol'
  },
  'Pituitary Tumors': {
    'Medication': 'Surgery, Radiation, Medications to shrink the tumor'
  },
  'Adrenal Insufficiency': {'Medication': 'Corticosteroids'},
  'Hyperparathyroidism': {
    'Medication': 'Surgery, Medications to manage calcium levels'
  },
  'Hypoparathyroidism': {'Medication': 'Calcium and Vitamin D supplements'},
  'Polycystic Ovary Syndrome (PCOS)': {
    'Medication': 'Birth control pills, Metformin'
  },
  'Endometriosis': {'Medication': 'Pain relievers, Hormone therapy, Surgery'},
  'Menopause': {'Medication': 'Hormone replacement therapy, Antidepressants'},
  'Pelvic Inflammatory Disease (PID)': {'Medication': 'Antibiotics'},
  'Ectopic Pregnancy': {'Medication': 'Methotrexate, Surgery'},
  'Miscarriage': {'Medication': 'Supportive care, Surgery'},
  'Placenta Previa': {'Medication': 'Bed rest, Surgery'},
  'Pre-eclampsia': {
    'Medication': 'Blood pressure medications, Delivery of the baby'
  },
  'Eclampsia': {'Medication': 'Antihypertensive drugs, Delivery of the baby'},
  'Gestational Diabetes': {'Medication': 'Dietary changes, Insulin'},
  'Fetal Alcohol Syndrome': {'Medication': 'Supportive care, Therapy'},
  'SIDS': {'Medication': 'Prevention through safe sleeping practices'},
  'Autism': {'Medication': 'Therapy, Behavioral interventions'},
  'Cerebral Palsy': {
    'Medication':
        'Physical therapy, Occupational therapy, Medications for muscle spasticity'
  },
  'Down Syndrome': {'Medication': 'Supportive care, Early intervention'},
  'Muscular Dystrophy': {
    'Medication': 'Physical therapy, Medications for muscle spasticity'
  },
  'Spina Bifida': {'Medication': 'Surgery, Physical therapy'},
  'Fragile X Syndrome': {'Medication': 'Supportive care, Behavioral therapy'},
  'Turner Syndrome': {'Medication': 'Hormone therapy, Growth hormone'},
  'Klinefelter Syndrome': {
    'Medication': 'Testosterone replacement therapy, Fertility treatment'
  },
  'Tay-Sachs Disease': {'Medication': 'Supportive care, Genetic counseling'},
  'PKU': {
    'Medication': 'Special diet, Medication to lower phenylalanine levels'
  },
  'Rickets': {'Medication': 'Vitamin D supplements, Calcium supplements'},
  'Scurvy': {'Medication': 'Vitamin C supplements'},
  'Beriberi': {'Medication': 'Thiamine supplements'},
  'Pellagra': {'Medication': 'Niacin supplements'},
  'Goiter': {'Medication': 'Iodine supplements, Thyroid hormone replacement'},
};

Map<String, List<String>> symptomDiseaseMapping = {
  'headache': [
    'Migraine',
    'Tension Headache',
    'High Blood Pressure',
    'Sinus Infection',
    'Cluster Headache'
  ],
  'dizziness': [
    'Dizziness',
    'Dehydration',
    'Migraine',
    'Anxiety',
    'Anemia',
    'Labyrinthitis',
    'Meniere\'s Disease',
    'dizziness',
    'Vertigo'
  ],
  'fatigue': [
    'Chronic Fatigue',
    'Depression',
    'Anemia',
    'Underactive Thyroid',
    'Mononucleosis',
    'Sleep Apnea'
  ],
  'flu': ['Flu', 'Common Cold'],
  'increased thirst': ['Type 2 Diabetes', 'Diabetes Insipidus'],
  'frequent urination': ['Type 2 Diabetes', 'Diabetes Insipidus'],
  'unexplained weight loss': [
    'Type 2 Diabetes',
    'Overactive Thyroid',
    'Cancer'
  ],
  'chest pain': [
    'Heart Disease',
    'Pneumonia',
    'GERD',
    'Panic Attack',
    'Pleurisy'
  ],
  'shortness of breath': [
    'Heart Disease',
    'COPD',
    'Asthma',
    'Anemia',
    'Pulmonary Embolism',
    'Heart Failure'
  ],
  'chronic cough': [
    'COPD',
    'Asthma',
    'GERD',
    'Bronchitis',
    'Common Cold',
    'Pneumonia'
  ],
  'nausea': [
    'Migraine',
    'Heart Disease',
    'Stomach Flu',
    'Pregnancy',
    'Gastroenteritis',
    'Vertigo'
  ],
  'sweating': ['Heart Disease', 'Overactive Thyroid', 'Menopause'],
  'joint pain': ['Arthritis', 'Lupus', 'Gout'],
  'swelling': ['Arthritis', 'Kidney Disease', 'Heart Failure'],
  'stiffness': ['Arthritis'],
  'persistent sad': ['Depression'],
  'loss of interest': ['Depression'],
  'changes in appetite': ['Depression', 'Eating Disorders'],
  'suicidal thoughts': ['Depression'],
  'excessive worry': ['Anxiety'],
  'muscle tension': ['Anxiety'],
  'memory loss': ['Alzheimer\'s', 'Vitamin B12 Deficiency'],
  'confusion': ['Alzheimer\'s', 'Electrolyte Imbalance'],
  'difficulty completing tasks': ['Alzheimer\'s', 'ADHD'],
  'changes in mood': ['Alzheimer\'s', 'Bipolar Disorder'],
  'diarrhea': ['Stomach Flu', 'IBS', 'Food Poisoning', 'Gastroenteritis'],
  'vomiting': ['Stomach Flu', 'Pregnancy', 'Food Poisoning', 'Gastroenteritis'],
  'abdominal cramps': ['Stomach Flu', 'IBS', 'Gastroenteritis'],
  'fever': ['Flu', 'Stomach Flu', 'Infection', 'Malaria', 'Dengue Fever'],
  'cold intolerance': ['Underactive Thyroid'],
  'dry skin': ['Underactive Thyroid', 'Eczema'],
  'hair loss': ['Underactive Thyroid', 'Alopecia'],
  'weight loss': ['Overactive Thyroid', 'Cancer', 'Chronic Infection'],
  'rapid heart rate': ['Overactive Thyroid', 'Panic Attack'],
  'anxiety': ['Overactive Thyroid', 'Generalized Anxiety Disorder'],
  'excessive sweating': [
    'Overactive Thyroid',
    'Menopause',
    'Hyperhidrosis',
    'Hyperthyroidism'
  ],
  'tremors': ['Overactive Thyroid', 'Parkinson\'s Disease'],
  'back pain': [
    'Muscle Strain',
    'Slipped Disc',
    'Osteoporosis',
    'Herniated Disc'
  ],
  'short-term memory loss': ['Concussion', 'Amnesia', 'Alcohol Abuse'],
  'abdominal pain': [
    'Stomach Inflammation',
    'Appendicitis',
    'Gallstones',
    'Diverticulitis'
  ],
  'sleeplessness': ['Insomnia', 'Anxiety', 'Depression', 'Sleep Apnea'],
  'insomnia': ['Insomnia', 'Sleep Apnea'],
  'sleep problems': ['Insomnia', 'Sleep Apnea'],
  'mood swings': ['Bipolar Disorder', 'Premenstrual Syndrome (PMS)'],
  'fainting': ['Fainting', 'Low Blood Pressure', 'Syncope'],
  'seizures': ['Epilepsy', 'Head Injury', 'Brain Tumor'],
  'numbness': ['Nerve Pain', 'Multiple Sclerosis'],
  'blurred vision': ['Glaucoma', 'Diabetes'],
  'digestive issues': ['IBS', 'GERD'],
  'difficulty swallowing': ['Difficulty Swallowing', 'Esophageal Cancer'],
  'skin rash': ['Eczema', 'Allergic Reaction', 'Psoriasis'],
  'excessive thirst': ['Diabetes Insipidus', 'Type 2 Diabetes'],
  'chest tightness': ['Asthma', 'Heart Disease'],
  'dry cough': ['COPD', 'Asthma'],
  'abdominal bloating': ['IBS', 'Ascites'],
  'constipation': [
    'IBS',
    'Underactive Thyroid',
    'Irritable Bowel Syndrome',
    'Hypothyroidism'
  ],
  'diarrhea alternating with constipation': ['IBS'],
  'difficulty focusing': ['ADHD', 'Depression'],
  'hyperactivity': ['ADHD'],
  'persistent itching': ['Eczema', 'Allergic Reaction', 'Liver Disease'],
  'sore throat': ['Common Cold', 'Flu', 'Strep Throat'],
  'runny nose': ['Common Cold', 'Flu'],
  'loss of appetite': ['Depression', 'Cancer', 'Anorexia'],
  'weight gain': ['Hypothyroidism', 'Cushing\'s Syndrome'],
  'muscle weakness': [
    'Multiple Sclerosis',
    'Amyotrophic Lateral Sclerosis (ALS)'
  ],
  'ringing in ears': ['Tinnitus'],
  'nosebleeds': ['High Blood Pressure', 'Nasal Trauma'],
  'coughing up blood': ['Tuberculosis', 'Lung Cancer'],
  'night sweats': ['Tuberculosis', 'Lymphoma'],
  'frequent infections': ['HIV/AIDS', 'Chronic Kidney Disease'],
  'easy bruising': ['Leukemia', 'Hemophilia'],
  'joint stiffness': ['Arthritis', 'Lupus'],
  'abdominal swelling': ['Liver Disease', 'Ascites'],
  'painful urination': ['UTI', 'Kidney Stones'],
  'blood in urine': ['Kidney Stones', 'Bladder Cancer'],
  'decreased urine output': ['Kidney Failure', 'Dehydration'],
  'frequent headaches': ['Migraine', 'Tension Headache'],
  'tingling sensation': ['Peripheral Neuropathy', 'Multiple Sclerosis'],
  'balance problems': ['Vertigo', 'Parkinson\'s Disease'],
  'difficulty walking': ['Multiple Sclerosis', 'Parkinson\'s Disease'],
  'speech difficulties': ['Stroke', 'Amyotrophic Lateral Sclerosis (ALS)'],
  'difficulty breathing': ['Asthma', 'COPD'],
  'chronic pain': ['Fibromyalgia', 'Chronic Fatigue Syndrome'],
  'loss of taste': ['COVID-19', 'Nasal Polyps'],
  'loss of smell': ['COVID-19', 'Nasal Polyps'],
  'flushing': ['Menopause', 'Carcinoid Syndrome'],
  'dry mouth': ['Sjogren\'s Syndrome', 'Dehydration'],
  'dry eyes': ['Sjogren\'s Syndrome', 'Allergies'],
  'itchy eyes': ['Allergies', 'Conjunctivitis'],
  'eye pain': ['Glaucoma', 'Uveitis'],
  'watery eyes': ['Allergies', 'Common Cold'],
  'hoarseness': ['Laryngitis', 'Thyroid Cancer'],
  'sensitivity to light': ['Migraine', 'Meningitis'],
  'irritability': ['Anxiety', 'Depression'],
  'trouble sleeping': ['Insomnia', 'Anxiety'],
  'nervousness': ['Anxiety', 'Hyperthyroidism'],
  'panic attacks': ['Panic Disorder', 'Anxiety'],
  'restlessness': ['Anxiety', 'ADHD'],
  'trembling': ['Parkinson\'s Disease', 'Essential Tremor'],
  'uncontrolled movements': ['Huntington\'s Disease', 'Tardive Dyskinesia'],
  'swollen glands': ['Infection', 'Lymphoma'],
  'bloating': ['Irritable Bowel Syndrome', 'Ovarian Cancer'],
  'coughing': ['Common Cold', 'Asthma'],
  'depression': ['Major Depressive Disorder', 'Bipolar Disorder'],
  'heart palpitations': ['Arrhythmia', 'Panic Attack'],
  'hearing loss': [
    'Ear Infection',
    'Age-related Hearing Loss',
    'Meniere\'s Disease'
  ],
  'itching': ['Eczema', 'Psoriasis'],
  'muscle cramps': ['Dehydration', 'Electrolyte Imbalance'],
  'rapid heartbeat': ['Tachycardia', 'Panic Attack'],
  'stomach pain': ['Gastritis', 'Peptic Ulcer'],
  'yellow skin': ['Jaundice', 'Hepatitis'],
};
