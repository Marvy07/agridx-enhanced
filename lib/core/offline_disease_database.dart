// Local plant pathology expert database covering all 38 classes from PlantVillage labels.txt.
// Provided for fast offline diagnosis summaries and treatment cards.

final Map<String, Map<String, dynamic>> offlinePathologyDatabase = {
  // --- APPLE ---
  'Apple___Apple_scab': {
    'description': 'Apple scab is a severe disease caused by the fungus Venturia inaequalis. It affects leaves, buds, and fruits, causing severe blemishes and early defoliation, reducing overall fruit yields.',
    'symptoms': [
      'Velvety, olive-green to black circular spots on leaves.',
      'Leaves twist, turn yellow, and drop prematurely.',
      'Sunken, scabby brown lesions on fruits, causing distortion and cracking.'
    ],
    'chemical_treatment': [
      {'product': 'Captan 80 WDG', 'dosage': '2.5 lbs per acre, spray at pink bud stage'},
      {'product': 'Myclobutanil (Nova 40W)', 'dosage': '3 - 5 oz per acre, apply at bloom'}
    ],
    'organic_treatment': [
      'Apply Sulfur-based sprays or Copper fungicides before rainy periods.',
      'Neem oil applications can help inhibit fungal spore germination.'
    ],
    'prevention': [
      'Rake and destroy fallen leaves in autumn to prevent overwintering.',
      'Prune trees to improve air circulation and sunlight penetration.',
      'Plant scab-resistant cultivars like Honeycrisp or Liberty.'
    ]
  },
  'Apple___Black_rot': {
    'description': 'Black rot is a fungal infection caused by Botryosphaeria obtusa. It attacks apple foliage (frogeye leaf spot), bark (cankers), and fruit (rot), rendering infected fruit unmarketable.',
    'symptoms': [
      'Leaves show "frogeye" spots with light centers and dark brown borders.',
      'Sunken, reddish-brown cankers on branches and tree trunks.',
      'Fruit develops a firm brown rot with concentric circles, eventually turning black.'
    ],
    'chemical_treatment': [
      {'product': 'Fludioxonil (Scholar)', 'dosage': '10 oz per 100 gallons of water'},
      {'product': 'Thiophanate-methyl (Topsin M)', 'dosage': '1 lb per acre, apply from petal fall stage'}
    ],
    'organic_treatment': [
      'Spray copper octanoate soap at 7-10 day intervals starting at green tip.',
      'Apply compost tea to strengthen plant immunity.'
    ],
    'prevention': [
      'Prune out dead wood, mummified fruits, and active cankers during winter.',
      'Maintain overall tree health through proper fertilization and watering.',
      'Avoid mechanical trunk or limb injuries which allow spore entry.'
    ]
  },
  'Apple___Cedar_apple_rust': {
    'description': 'Cedar apple rust is a disease caused by Gymnosporangium juniperi-virginianae. It requires both apples and red cedars (junipers) to complete its complex two-year life cycle.',
    'symptoms': [
      'Bright orange-yellow spots on upper leaf surfaces.',
      'Fringe-like cup structures (aecia) on the underside of leaves.',
      'Premature defoliation and dwarfing or spotting of fruits.'
    ],
    'chemical_treatment': [
      {'product': 'Mancozeb (Penncozeb 75DF)', 'dosage': '3 lbs per acre, apply at pink stage'},
      {'product': 'Propiconazole (Orbit)', 'dosage': '4 fl oz per acre, apply at bloom'}
    ],
    'organic_treatment': [
      'Apply Sulfur or copper-based dusts early in the season.',
      'Apply Serenade ASO (Bacillus subtilis) at 2-4 qts per acre.'
    ],
    'prevention': [
      'Remove nearby red cedar or juniper trees within a 1-mile radius.',
      'Prune out brown cedar galls found on junipers before spring rains.',
      'Grow rust-resistant apple cultivars like Red Delicious or Empire.'
    ]
  },
  'Apple___healthy': _healthyTemplate('Apple'),

  // --- BLUEBERRY ---
  'Blueberry___healthy': _healthyTemplate('Blueberry'),

  // --- CHERRY ---
  'Cherry___healthy': _healthyTemplate('Cherry'),
  'Cherry___Powdery_mildew': {
    'description': 'Cherry powdery mildew is caused by Podosphaera clandestina. It infects young foliage, twigs, and fruit, forming a powdery white layer that stunts growth and blemishes the cherries.',
    'symptoms': [
      'White, powdery patches of fungal mycelium on leaf undersides.',
      'Leaves curl upward, become distorted, and feel brittle.',
      'Web-like white patches on developing cherry fruits, causing scarring.'
    ],
    'chemical_treatment': [
      {'product': 'Quinoxyfen (Quintec)', 'dosage': '8.2 fl oz per acre at early petal fall'},
      {'product': 'Trifloxystrobin (Flint 50WG)', 'dosage': '2 oz per acre, do not exceed 4 sprays/season'}
    ],
    'organic_treatment': [
      'Apply Potassium Bicarbonate (Kaligreen) at 2.5 lbs per acre.',
      'Spray horticultural oils or neem oil to suffocate powdery mildew spores.'
    ],
    'prevention': [
      'Prune lower canopies to maximize air flow and reduce humidity.',
      'Avoid overhead sprinklers; use drip irrigation to keep foliage dry.',
      'Remove and destroy infected leaves and shoots at first sight.'
    ]
  },

  // --- CORN ---
  'Corn___Cercospora_leaf_spot Gray_leaf_spot': {
    'description': 'Gray leaf spot is caused by Cercospora zeae-maydis. It is a highly destructive corn disease that thrives in warm, humid weather, leading to severe leaf blight and lodging.',
    'symptoms': [
      'Small, tan spots with yellow halos that expand into long rectangular lesions.',
      'Lesions are restricted by leaf veins, giving them a distinct blocky shape.',
      'Greyish casting on lesions during damp periods due to fungal sporulation.'
    ],
    'chemical_treatment': [
      {'product': 'Pyraclostrobin (Headline)', 'dosage': '6 fl oz per acre at tasseling stage'},
      {'product': 'Azoxystrobin + Propiconazole (Quilt)', 'dosage': '14 fl oz per acre, apply at V12 stage'}
    ],
    'organic_treatment': [
      'Apply bio-fungicides containing Bacillus amyloliquefaciens.',
      'Apply copper octanoate early in the season.'
    ],
    'prevention': [
      'Rotate crops with soybeans or alfalfa for at least one year.',
      'Use deep tillage to bury infected crop residue in the soil.',
      'Select corn hybrids with high resistance to Gray Leaf Spot.'
    ]
  },
  'Corn___Common_rust': {
    'description': 'Common rust is caused by Puccinia sorghi. It is a foliar disease that produces powdery rust pustules, causing premature leaf death and lowering grain yields.',
    'symptoms': [
      'Oval to elongated cinnamon-brown pustules on both leaf surfaces.',
      'Pustules rupture to release powdery, orange-red spores.',
      'Leaves turn yellow, dry up, and die in severe cases.'
    ],
    'chemical_treatment': [
      {'product': 'Tebuconazole (Folicur 3.6F)', 'dosage': '4 fl oz per acre on early symptoms'},
      {'product': 'Pyraclostrobin + Metconazole (Headline AMP)', 'dosage': '10 fl oz per acre'}
    ],
    'organic_treatment': [
      'Apply sulfur dusts at first sign of rust pustules.',
      'Foliar spray with biological controls containing Trichoderma harzianum.'
    ],
    'prevention': [
      'Plant rust-resistant corn hybrids with Rp-resistant genes.',
      'Plant corn early in the season to avoid late-summer spore peaks.',
      'Ensure balanced nitrogen fertilization; excess nitrogen favors rust.'
    ]
  },
  'Corn___healthy': _healthyTemplate('Corn'),
  'Corn___Northern_Leaf_Blight': {
    'description': 'Northern corn leaf blight is caused by Exserohilum turcicum. It is a damaging disease producing large cigar-shaped lesions, leading to reduced photosynthetic capacity.',
    'symptoms': [
      'Long, cigar-shaped, grey-green to tan lesions (1-6 inches long).',
      'Dark, dusty spores forming on lesions during damp weather.',
      'Heavy spotting leading to rapid leaf wilting and death.'
    ],
    'chemical_treatment': [
      {'product': 'Prothioconazole (Proline 480SC)', 'dosage': '5.7 fl oz per acre'},
      {'product': 'Strobilurin + Triazole (Trivapro)', 'dosage': '13.7 fl oz per acre at VT-R1'}
    ],
    'organic_treatment': [
      'Apply microbial sprays containing Bacillus subtilis.',
      'Apply neem-based formulations early to suppress spore expansion.'
    ],
    'prevention': [
      'Rotate crop fields out of corn for 1-2 years to decompose residues.',
      'Implement chisel plowing to bury infested stalks and foliage.',
      'Plant corn hybrids showing high tolerance to Northern Leaf Blight.'
    ]
  },

  // --- GRAPE ---
  'Grape___Black_rot': {
    'description': 'Grape black rot is caused by Guignardia bidwellii. It infects leaves, shoots, and berries. It can destroy the entire grape crop under warm, humid conditions.',
    'symptoms': [
      'Reddish-brown circular spots on leaves with tiny black spore pimples.',
      'Purple-black sunken lesions on petioles and young shoots.',
      'Grapes turn soft, rot, and shrivel into hard, black, wrinkled mummies.'
    ],
    'chemical_treatment': [
      {'product': 'Mancozeb (Dithane M45)', 'dosage': '3 - 4 lbs per acre, apply pre-bloom'},
      {'product': 'Tebuconazole (Elite 45DF)', 'dosage': '4 oz per acre, apply from immediate pre-bloom'}
    ],
    'organic_treatment': [
      'Apply copper hydroxide sprays before rainfall events.',
      'Apply lime-sulfur early in the spring before bud break.'
    ],
    'prevention': [
      'Remove and bury or burn all shriveled grape mummies from vines.',
      'Prune and train vines to a high trellis to facilitate rapid drying.',
      'Keep vineyard floors free of weeds to improve lower canopy air flow.'
    ]
  },
  'Grape___Esca_(Black_Measles)': {
    'description': 'Esca, or Black Measles, is a complex wood-rotting disease caused by Phaeomoniella chlamydospora and other fungi. It restricts water flow, causing leaf scorching and fruit spotting.',
    'symptoms': [
      'Leaves display "tiger-stripe" patterns with yellow/red edges and green centers.',
      'Dark purple-brown spots (measles) scattered across grape skin.',
      'Sudden wilting of the entire vine (apoplexy) in extremely hot weather.'
    ],
    'chemical_treatment': [
      {'product': 'Myclobutanil (Rally 40W)', 'dosage': '4 oz per acre (limited efficacy, focuses on wood protection)'},
      {'product': 'Topsin M (Paint cankers/pruning wounds)', 'dosage': 'Brush paste onto active pruning cuts'}
    ],
    'organic_treatment': [
      'Apply Trichoderma-based pruning wound protectants (e.g., Vintec).',
      'Spray foliar liquid seaweed to reduce vine physiological stress.'
    ],
    'prevention': [
      'Avoid pruning during wet periods when fungal spores are airborne.',
      'Protect pruning wounds immediately with sealants or fungicides.',
      'Remove and destroy heavily diseased or dead vines to protect the block.'
    ]
  },
  'Grape___healthy': _healthyTemplate('Grape'),
  'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)': {
    'description': 'Grape leaf blight is caused by Pseudocercospora vitis. It primarily infects older foliage, causing late-season spots and premature leaf drop that weakens the vine.',
    'symptoms': [
      'Dull brown, irregular spots on leaves, starting on lower canopy.',
      'Lesions grow together, turning large sections of leaf dry and brown.',
      'Dark grey moldy growth on the underside of spots during damp periods.'
    ],
    'chemical_treatment': [
      {'product': 'Azoxystrobin (Abound)', 'dosage': '11 fl oz per acre, do not apply near apples'},
      {'product': 'Copper Sulfate + Lime (Bordeaux mixture)', 'dosage': '8 lbs per 100 gallons'}
    ],
    'organic_treatment': [
      'Apply copper fungicides or sulfur dusts early in the season.',
      'Use organic potassium bicarbonate to alter leaf pH and inhibit fungus.'
    ],
    'prevention': [
      'Rake and compost or bury fallen grape leaves in the winter.',
      'Prune lower canopy leaves to increase air flow and lower dampness.',
      'Ensure balanced potassium nutrition to improve grape leaf stamina.'
    ]
  },

  // --- ORANGE ---
  'Orange___Haunglongbing_(Citrus_greening)': {
    'description': 'Citrus greening (HLB) is caused by the bacterium Candidatus Liberibacter asiaticus, spread by the Asian citrus psyllid. It is currently the most devastating citrus disease worldwide.',
    'symptoms': [
      'Asymmetrical yellow mottling on leaves ("blotchy mottle").',
      'Stunted, upright shoots with small, pale green leaves.',
      'Small, lopsided fruit that remains green at the bottom and tastes bitter.'
    ],
    'chemical_treatment': [
      {'product': 'Imidacloprid (Admire Pro)', 'dosage': '7 fl oz per acre (to control Psyllid vector)'},
      {'product': 'Thiamethoxam (Actara)', 'dosage': '4 oz per acre (foliar insecticide for vector control)'}
    ],
    'organic_treatment': [
      'Release Tamarixia radiata wasps (parasitoid of Asian citrus psyllid).',
      'Spray horticultural mineral oils or neem oil to disrupt psyllid breeding.'
    ],
    'prevention': [
      'Plant only certified disease-free citrus nursery trees.',
      'Regularly scout and aggressively control psyllid vector populations.',
      'Remove and destroy infected trees immediately to prevent field spread.'
    ]
  },

  // --- PEACH ---
  'Peach___Bacterial_spot': {
    'description': 'Bacterial spot is caused by Xanthomonas arboricola pv. pruni. It damages peach leaves, twigs, and fruit, causing severe defoliation and sunken fruit cracks.',
    'symptoms': [
      'Small, water-soaked grey spots on leaves that turn purple and fall out ("shot-holes").',
      'Deep, pitted cracks on peach skins, oozing gum during wet weather.',
      'Girdling black cankers on twigs, killing terminal shoots.'
    ],
    'chemical_treatment': [
      {'product': 'Oxytetracycline (Mycoshield)', 'dosage': '1.5 lbs per 100 gallons water, apply weekly'},
      {'product': 'Copper Hydroxide (Kocide 3000)', 'dosage': '0.5 lbs per acre, use only during dormant stage'}
    ],
    'organic_treatment': [
      'Apply copper soap formulations at low rates during the foliage season.',
      'Use foliar application of biological control Bacillus subtilis.'
    ],
    'prevention': [
      'Avoid high-nitrogen fertilizer which triggers highly susceptible soft shoots.',
      'Plant resistant cultivars such as Redhaven, Loring, or Cresthaven.',
      'Prune terminal cankers during dormant winter pruning.'
    ]
  },
  'Peach___healthy': _healthyTemplate('Peach'),

  // --- PEPPER ---
  'Pepper,_bell___Bacterial_spot': {
    'description': 'Bacterial spot on bell peppers is caused by Xanthomonas campestris pv. vesicatoria. It thrives in warm, rainy climates, causing spot lesions, leaf drop, and blistered fruit.',
    'symptoms': [
      'Small, circular dark spots on leaves with yellow halos.',
      'Spots merge, turn brown, and leaf drops off, causing sunscald on peppers.',
      'Raised, rough, wart-like brown spots on the pepper fruits.'
    ],
    'chemical_treatment': [
      {'product': 'Copper Sulfate + Mancozeb (Manzate Flowable)', 'dosage': '1.6 qts per acre, spray at 7-day intervals'},
      {'product': 'Streptomycin (Agri-Mycin 17)', 'dosage': '1 lb per 100 gallons (for greenhouse transplants only)'}
    ],
    'organic_treatment': [
      'Spray copper octanoate (soap) or Serenade Optima.',
      'Use garlic extract sprays or compost teas to inhibit bacteria.'
    ],
    'prevention': [
      'Purchase and plant only certified pathogen-free pepper seeds and starts.',
      'Practice a strict 2-year crop rotation without solanaceous crops.',
      'Avoid overhead watering; use drip lines to keep pepper leaves dry.'
    ]
  },
  'Pepper,_bell___healthy': _healthyTemplate('Pepper, bell'),

  // --- POTATO ---
  'Potato___Early_blight': {
    'description': 'Potato early blight is caused by the fungus Alternaria solani. It primarily damages older foliage, producing dry concentric spots that reduce potato tuber sizes.',
    'symptoms': [
      'Dark brown spots on older leaves displaying concentric rings ("target board" pattern).',
      'Spots develop yellow margins and expand, causing leaves to dry up.',
      'Sunken, dry, brown leathery lesions on potato tubers.'
    ],
    'chemical_treatment': [
      {'product': 'Chlorothalonil (Bravo Weather Stik)', 'dosage': '1.5 pints per acre, apply on 7-10 day schedule'},
      {'product': 'Boscalid (Endura)', 'dosage': '4.5 oz per acre, apply at canopy closure'}
    ],
    'organic_treatment': [
      'Foliar spray with Copper Hydroxide or Copper Octanoate.',
      'Apply organic bio-fungicides containing Bacillus amyloliquefaciens.'
    ],
    'prevention': [
      'Rotate crops with non-solanaceous options (corn, wheat) for 2-3 years.',
      'Provide adequate nitrogen and potassium; stressed plants are highly susceptible.',
      'Destroy all cull piles and harvest debris to eliminate overwintering spores.'
    ]
  },
  'Potato___healthy': _healthyTemplate('Potato'),
  'Potato___Late_blight': {
    'description': 'Late blight is caused by the oomycete Phytophthora infestans. It is an extremely aggressive disease capable of wiping out entire potato fields in days under cool, wet conditions.',
    'symptoms': [
      'Water-soaked dark green/black lesions starting at leaf tips and margins.',
      'White, downy, powdery fungal growth on the underside of infected leaves.',
      'Tubers develop a firm, dark brown dry rot beneath the skin.'
    ],
    'chemical_treatment': [
      {'product': 'Mefenoxam + Mancozeb (Ridomil Gold MZ)', 'dosage': '2.5 lbs per acre'},
      {'product': 'Fluopicolide (Presidio)', 'dosage': '4 fl oz per acre, tank-mix with another fungicide'}
    ],
    'organic_treatment': [
      'Apply copper hydroxide aggressively at the first disease alert.',
      'Apply biological agents like Bacillus subtilis to inhibit oomycete spread.'
    ],
    'prevention': [
      'Plant only certified disease-free seed tubers.',
      'Kill potato vines 2 weeks before harvest to prevent tuber infection.',
      'Immediately destroy and bury late blight-infected potato plants.'
    ]
  },

  // --- RASPBERRY ---
  'Raspberry___healthy': _healthyTemplate('Raspberry'),

  // --- SOYBEAN ---
  'Soybean___healthy': _healthyTemplate('Soybean'),

  // --- SQUASH ---
  'Squash___Powdery_mildew': {
    'description': 'Squash powdery mildew is caused by Podosphaera xanthii. It quickly spreads a white fungal layer over leaves, reducing photosynthesis and leading to sunburned squash.',
    'symptoms': [
      'White, powdery circular spots on both surfaces of squash leaves.',
      'Leaves turn yellow, brown, and shrivel, exposing squash to hot sun.',
      'Stunted plant growth and reduced fruit yield and sweetness.'
    ],
    'chemical_treatment': [
      {'product': 'Triflumizole (Procure 480SC)', 'dosage': '6 fl oz per acre at first symptom'},
      {'product': 'Cyflufenamid (Torino)', 'dosage': '3.4 fl oz per acre, apply once per season'}
    ],
    'organic_treatment': [
      'Spray dilute milk solutions (40% milk, 60% water) on leaves in bright sun.',
      'Apply neem oil, potassium bicarbonate, or sulfur-based organic sprays.'
    ],
    'prevention': [
      'Ensure wide plant spacing for excellent ventilation in the squash patch.',
      'Plant squash in areas with full, direct sunlight; shade favors mildew.',
      'Choose powdery-mildew-resistant squash varieties.'
    ]
  },

  // --- STRAWBERRY ---
  'Strawberry___healthy': _healthyTemplate('Strawberry'),
  'Strawberry___Leaf_scorch': {
    'description': 'Strawberry leaf scorch is caused by Diplocarpon earlianum. It infects leaves, runners, and fruit caps, producing dark purple spots that dry out the leaf canopy.',
    'symptoms': [
      'Numerous small, dark purple or reddish spots on upper leaf surfaces.',
      'Spots enlarge and merge, turning the leaf dry, brown, and scorched.',
      'Infected strawberry fruit caps turn brown and dry prematurely.'
    ],
    'chemical_treatment': [
      {'product': 'Captan 50 WP', 'dosage': '3 - 6 lbs per acre, apply weekly'},
      {'product': 'Thiophanate-methyl (Topsin 4.5FL)', 'dosage': '20 fl oz per acre at bloom'}
    ],
    'organic_treatment': [
      'Apply copper fungicides or sulfur dusts early in the season.',
      'Use biological control sprays containing Bacillus amyloliquefaciens.'
    ],
    'prevention': [
      'Renovate strawberry beds annually to thin out dense canopies.',
      'Keep beds weed-free and water using drip lines to avoid foliage dampness.',
      'Remove and destroy infected leaves during spring bed cleaning.'
    ]
  },

  // --- TOMATO ---
  'Tomato___Bacterial_spot': {
    'description': 'Bacterial spot is caused by Xanthomonas species. It attacks all above-ground parts of the tomato plant, causing severe spotting, leaf dropping, and scabbed fruit.',
    'symptoms': [
      'Small, circular dark spots on leaves that appear greasy or water-soaked.',
      'Leaves turn yellow, dry up, and fall off, exposing fruit to sunscald.',
      'Small, raised black blister-like spots on tomatoes, eventually turning scabby.'
    ],
    'chemical_treatment': [
      {'product': 'Copper Hydroxide + Mancozeb (Kocide + Manzate)', 'dosage': '1.5 lbs + 1.5 lbs per acre, spray every 7 days'},
      {'product': 'Actigard 50WG (Systemic Acquired Resistance)', 'dosage': '0.5 oz per acre, stimulates plant defenses'}
    ],
    'organic_treatment': [
      'Spray copper octanoate soap at first signs.',
      'Apply foliar microbial spray containing Bacillus subtilis.'
    ],
    'prevention': [
      'Plant certified disease-free seeds and transplants.',
      'Avoid working in tomato fields when leaves are wet from dew or rain.',
      'Practice a 3-year crop rotation out of solanaceous plant families.'
    ]
  },
  'Tomato___Early_blight': {
    'description': 'Early blight is a fungal infection caused by Alternaria solani. It targets older tomato foliage, creating bullseye lesions that slowly dry out the entire branch canopy.',
    'symptoms': [
      'Concentric dark rings on older leaves forming a "target" pattern.',
      'Leaves turn yellow and drop off, beginning from the bottom of the plant.',
      'Dark, sunken, leathery lesions on the stem near the soil line.'
    ],
    'chemical_treatment': [
      {'product': 'Chlorothalonil (Daconil Ultrex)', 'dosage': '1.4 lbs per acre, repeat every 7-10 days'},
      {'product': 'Azoxystrobin (Quadris)', 'dosage': '6 fl oz per acre, alternate with chlorothalonil'}
    ],
    'organic_treatment': [
      'Foliar spray with Copper Soap or Potassium Bicarbonate.',
      'Mulch heavily around the tomato bases to prevent soil splashing.'
    ],
    'prevention': [
      'Prune the lower 12-18 inches of tomato branches to prevent soil contact.',
      'Maintain adequate plant spacing to allow rapid drying of leaves.',
      'Rake and destroy all tomato vine debris after the harvesting season.'
    ]
  },
  'Tomato___healthy': _healthyTemplate('Tomato'),
  'Tomato___Late_blight': {
    'description': 'Late blight is a devastating oomycete infection caused by Phytophthora infestans. It spreads with extreme speed in wet, cool weather, rotting leaves and fruit.',
    'symptoms': [
      'Large, irregular dark brown or water-soaked greasy patches on leaves.',
      'Delicate white fuzzy mold on leaf undersides during wet mornings.',
      'Large, firm, greasy golden-brown spots on green and red tomatoes.'
    ],
    'chemical_treatment': [
      {'product': 'Mancozeb (Manzate Pro-Stick)', 'dosage': '2 lbs per acre, apply proactively'},
      {'product': 'Mandipropamid (Revus)', 'dosage': '8 fl oz per acre, highly effective against late blight'}
    ],
    'organic_treatment': [
      'Apply Copper Octanoate aggressively at the first late-blight local alert.',
      'Spray organic biologicals like Bacillus amyloliquefaciens.'
    ],
    'prevention': [
      'Do not plant potatoes and tomatoes in adjacent plots (diseases cross over).',
      'Provide overhead protection (greenhouse/high tunnels) if possible.',
      'Promptly pull, bag, and destroy any late-blight infected tomato plants.'
    ]
  },
  'Tomato___Leaf_Mold': {
    'description': 'Tomato leaf mold is caused by Passalora fulva. It is primarily a greenhouse tomato disease that thrives in high humidity, causing pale leaf spots and mold coating.',
    'symptoms': [
      'Pale green or yellow spots on upper leaf surfaces.',
      'Olive-green to purple velvety mold on the underside of leaves.',
      'Leaves wilt, die, and drop, resulting in reduced fruit sizes.'
    ],
    'chemical_treatment': [
      {'product': 'Difenoconazole + Cyprodinil (Inspire Super)', 'dosage': '16 fl oz per acre'},
      {'product': 'Pyrimethanil (Scala)', 'dosage': '7 fl oz per acre, apply at first symptom'}
    ],
    'organic_treatment': [
      'Apply copper octanoate or sulfur-based sprays.',
      'Foliar spray with potassium bicarbonate to suppress leaf mold.'
    ],
    'prevention': [
      'Lower greenhouse humidity below 85% using ventilation and fans.',
      'Keep temperatures warm; prune dense tomato foliage to improve airflow.',
      'Grow leaf-mold-resistant greenhouse tomato varieties.'
    ]
  },
  'Tomato___Septoria_leaf_spot': {
    'description': 'Septoria leaf spot is caused by the fungus Septoria lycopersici. It is a common foliar disease that produces thousands of tiny spots, leading to rapid defoliation.',
    'symptoms': [
      'Numerous small circular spots (1/8 inch) with dark borders and grey centers.',
      'Tiny black specks (fruiting bodies) visible inside the grey spot centers.',
      'Bottom leaves turn yellow, dry up, and fall off in large numbers.'
    ],
    'chemical_treatment': [
      {'product': 'Chlorothalonil (Bravo Weather Stik)', 'dosage': '2 pints per acre'},
      {'product': 'Pyraclostrobin (Cabrio EG)', 'dosage': '8 oz per acre, limit to 2 consecutive sprays'}
    ],
    'organic_treatment': [
      'Apply Copper hydroxide or copper octanoate at 7-day intervals.',
      'Mulch soil heavily to prevent overwintered spores from splashing up.'
    ],
    'prevention': [
      'Maintain a strict 2-year crop rotation out of tomatoes.',
      'Prune lower branches and water strictly with drip irrigation.',
      'Destroy all weeds in the solanaceous family (like nightshade) near fields.'
    ]
  },
  'Tomato___Spider_mites Two-spotted_spider_mite': {
    'description': 'The two-spotted spider mite (Tetranychus urticae) is a tiny sap-sucking pest. Mite colonies multiply rapidly in hot, dry weather, causing stippled leaves and webbing.',
    'symptoms': [
      'Tiny yellow or white speckles (stippling) on upper leaf surfaces.',
      'Fine silk webbing covering leaves, stems, and tomato clusters.',
      'Leaves turn bronze, dry out, and drop off; plants look dusty and weak.'
    ],
    'chemical_treatment': [
      {'product': 'Abamectin (Agri-Mek SC)', 'dosage': '2.25 fl oz per acre, apply when mites appear'},
      {'product': 'Bifenazate (Acramite 50WS)', 'dosage': '0.75 lbs per acre, highly selective miticide'}
    ],
    'organic_treatment': [
      'Release predatory mites (Phytoseiulus persimilis) into the crop canopy.',
      'Spray plants with insecticidal soap, neem oil, or horticultural oils.'
    ],
    'prevention': [
      'Keep tomato plants well-watered; drought-stressed plants attract mites.',
      'Foliar spray with overhead water occasionally to wash off mite colonies.',
      'Remove and destroy heavily infested weed hosts around tomatoes.'
    ]
  },
  'Tomato___Target_Spot': {
    'description': 'Target spot is caused by the fungus Corynespora cassiicola. It attacks tomato foliage and fruits, creating circular lesions with distinct target-like rings.',
    'symptoms': [
      'Circular tan spots on leaves with prominent concentric target rings.',
      'Spots grow together, causing large patches of dead leaf tissue.',
      'Sunken, circular dark lesions on tomato fruits, rotting deep into pulp.'
    ],
    'chemical_treatment': [
      {'product': 'Azoxystrobin + Difenoconazole (Quadris Top)', 'dosage': '8 fl oz per acre'},
      {'product': 'Penthiopyrad (Fontelis)', 'dosage': '16 fl oz per acre, apply at early bloom'}
    ],
    'organic_treatment': [
      'Spray copper hydroxide at weekly intervals.',
      'Foliar application of bio-fungicides like Bacillus amyloliquefaciens.'
    ],
    'prevention': [
      'Ensure wide spacing for excellent ventilation and leaf drying.',
      'Prune tomato sucker shoots to increase internal canopy air currents.',
      'Eradicate and destroy infected leaves and crop residue immediately.'
    ]
  },
  'Tomato___Tomato_mosaic_virus': {
    'description': 'Tomato mosaic virus (ToMV) is a highly contagious viral pathogen. It stunts growth, distorts leaves, and causes internal browning of tomato fruits.',
    'symptoms': [
      'Mottled light and dark green patterns ("mosaic") on leaves.',
      'Leaves become narrow, distorted, and stringy ("fern-leaf" symptoms).',
      'Fruit develops yellowish rings and internal brown corky tissue.'
    ],
    'chemical_treatment': [
      {'product': 'No Chemical Treatment Available', 'dosage': 'Viruses cannot be cured with chemicals.'}
    ],
    'organic_treatment': [
      'Foliar spray with dry milk solutions to reduce mechanical virus transmission.',
      'Apply compost extracts to boost general plant physiological stamina.'
    ],
    'prevention': [
      'Wash hands thoroughly with soap and water before handling tomato plants.',
      'Disinfect pruning tools in a 20% dry milk solution or bleach between plants.',
      'Remove and burn infected tomato plants immediately; do not compost.'
    ]
  },
  'Tomato___Tomato_Yellow_Leaf_Curl_Virus': {
    'description': 'Tomato yellow leaf curl virus (TYLCV) is a highly destructive virus transmitted by whiteflies (Bemisia tabaci). It halts tomato growth, preventing fruit production.',
    'symptoms': [
      'Severe stunting and erect growth of the entire tomato plant.',
      'Leaves curl upward and inward, turning pale yellow or chlorotic.',
      'Blossoms drop off, resulting in zero fruit set on newly infected plants.'
    ],
    'chemical_treatment': [
      {'product': 'Acetamiprid (Assail 30SG)', 'dosage': '2.5 oz per acre (to control Whitefly vector)'},
      {'product': 'Spiromesifen (Oberon 2SC)', 'dosage': '8 fl oz per acre (controls whitefly nymphs)'}
    ],
    'organic_treatment': [
      'Introduce natural predators like ladybugs or lacewings to eat whiteflies.',
      'Use yellow sticky cards to trap whiteflies and spray with neem oil.'
    ],
    'prevention': [
      'Plant TYLCV-resistant tomato cultivars like Tygress or Sakata starts.',
      'Use UV-reflective silver plastic mulches to repel flying whiteflies.',
      'Cover young transplants with fine mesh floating row covers.'
    ]
  }
};

// Helper template for healthy crops
Map<String, dynamic> _healthyTemplate(String cropName) {
  return {
    'description': 'This $cropName leaf specimen displays exceptional cell turgor, ideal chlorophyll density, and a complete absence of active fungal, bacterial, viral, or insect pathologies.',
    'symptoms': [
      'Consistent, vibrant green color across the leaf surface.',
      'Crisp, firm leaf margins with no necrotic drying or spots.',
      'Smooth, intact leaf veins with standard vascular distribution.'
    ],
    'chemical_treatment': [
      {'product': 'No Chemical Fungicide/Insecticide Needed', 'dosage': 'Maintain standard fertilization based on soil tests.'}
    ],
    'organic_treatment': [
      'Apply aged organic compost around the drip line to enrich the root zone.',
      'Apply mulching (straw, woodchips) to maintain soil moisture and cool roots.'
    ],
    'prevention': [
      'Practice deep, infrequent watering at the base of the plant to keep leaves dry.',
      'Ensure proper spacing to allow maximum sunshine and air movement.',
      'Conduct bi-weekly visual inspections to catch any pests early.'
    ]
  };
}
