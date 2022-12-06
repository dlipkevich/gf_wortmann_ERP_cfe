﻿#Область ОсновныеДействия
//Выбираем из РС гф_ДвижениеКодовМаркировкиИзВнешнихСистем записи по которым не созданы документы движения
//Получаем настройки 
//Создаем документы 
Процедура ВыполнитьОсновныеДействия() Экспорт
	
	ВидДвиженияВыводИзОборота = Перечисления.ВидыОперацийИСМП.ВыводИзОборотаПродажаПоОбразцамДистанционнаяПродажа;
	ВидДвиженияВозвратВОборот = Перечисления.ВидыОперацийИСМП.ВозвратВОборотПриДистанционномСпособеПродажи;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ВыводИзОборота", ВидДвиженияВыводИзОборота);
	Запрос.УстановитьПараметр("ВозвратВОборот", ВидДвиженияВозвратВОборот);
	Запрос.МенеджерВременныхТаблиц = новый МенеджерВременныхТаблиц;
	Запрос.Текст = ПолучитьТекстЗапросаДвиженияКМ(); 
	Результат = Запрос.ВыполнитьПакет();
	
	ВыборкаВыводИзОборота = Результат.Получить(Результат.Количество()-2).Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	ВыборкаВозвратВоборот = Результат.Получить(Результат.Количество()-1).Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	ОбработатьВыборкуВыводИзОборота(ВыборкаВыводИзОборота, ВидДвиженияВыводИзОборота);
	
	ОбработатьВыборкуВозвратВОборот(ВыборкаВозвратВоборот, ВидДвиженияВозвратВОборот);
	
КонецПроцедуры
#КонецОбласти

#Область ОбработкаВыборки
Процедура ОбработатьВыборкуВыводИзОборота(Выборка, ВидДвижения);
	
	текКомментарий = "Вывод из оборота кодов отгруженных через ";
	
	Пока Выборка.Следующий() Цикл
		ТекОрганизация = Выборка.Организация;
		ВыборкаВнешняяСистема = Выборка.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Пока ВыборкаВнешняяСистема.Следующий() Цикл
			ТекВнешняяСистема = ВыборкаВнешняяСистема.ВнешняяСистема;
			ГруппироватьДокументыПоДате = НайтиНастройкуГруппировки(текОрганизация, текВнешняяСистема);    // по-умолчанию ложь
			ВыборкаДатаОперации = ВыборкаВнешняяСистема.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			Пока ВыборкаДатаОперации.Следующий() Цикл
				ТекДатаОперации = ВыборкаДатаОперации.ДатаОперации;
				ВыборкаНомерЗаказа = ВыборкаДатаОперации.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
				СтруктураШапки = Новый Структура;
				СтруктураШапки.Вставить("Дата", ТекДатаОперации);
				СтруктураШапки.Вставить("Организация", ТекОрганизация);
				СтруктураШапки.Вставить("Операция", ВидДвижения);
				СтруктураШапки.Вставить("ВидПродукции", Перечисления.ВидыПродукцииИС.Обувь);
				СтруктураШапки.Вставить("ДатаПервичногоДокумента", ТекДатаОперации);
				СтруктураШапки.Вставить("НаименованиеПервичногоДокумента", "Заказ покупателя");
				СтруктураШапки.Вставить("ВидПервичногоДокумента", Перечисления.ВидыПервичныхДокументовИСМП.Прочее);
				СтруктураШапки.Вставить("Ответственный", ПараметрыСеанса.ТекущийПользователь);
				Если ГруппироватьДокументыПоДате Тогда
					СтруктураШапки.Вставить("НомерПервичногоДокумента", "б/н");
					СтруктураШапки.Вставить("Комментарий", текКомментарий + ТекВнешняяСистема + " за "+Формат(ТекДатаОперации, "ДЛФ=Д")); 
					ДокВывода = Документы.ВыводИзОборотаИСМП.СоздатьДокумент();
					ЗаполнитьЗначенияСвойств(ДокВывода, СтруктураШапки);
					тзДляЗаписиВРС = ПолучитьТЗДляЗаписиВРС();
				КонецЕсли;
				Пока ВыборкаНомерЗаказа.Следующий() Цикл;
					текНомерЗаказа = ВыборкаНомерЗаказа.НомерЗаказа;
					ВыборкаТовары = ВыборкаНомерЗаказа.Выбрать();
					Если Не ГруппироватьДокументыПоДате Тогда
						СтруктураШапки.Вставить("НомерПервичногоДокумента", текНомерЗаказа);
						ДокВывода = Документы.ВыводИзОборотаИСМП.СоздатьДокумент();
						ЗаполнитьЗначенияСвойств(ДокВывода, СтруктураШапки);
						тзДляЗаписиВРС = ПолучитьТЗДляЗаписиВРС();
					КонецЕсли; 
					
					тчТовары = ДокВывода.Товары;
					тчШКУпаковок = ДокВывода.ШтрихкодыУпаковок;
					
					текДатаЗаказа = Дата(1,1,1);
					Пока ВыборкаТовары.Следующий() Цикл
						Если НЕ ЗначениеЗаполнено(текДатаЗаказа) Тогда
							текДатаЗаказа = ВыборкаТовары.ДатаЗаказа;
							Если НЕ ГруппироватьДокументыПоДате Тогда
								ДокВывода.ДатаПервичногоДокумента = текДатаЗаказа;
								ДокВывода.Комментарий = текКомментарий + ТекВнешняяСистема + " по заказу №"+ текНомерЗаказа + " от " + Формат(текДатаЗаказа, "ДЛФ=Д");
							КонецЕсли;
						КонецЕсли;
						//Делаем запись в ТЗ для заполнения данных В РС
						нСтрокаРС = тзДляЗаписиВРС.Добавить();
						ЗаполнитьЗначенияСвойств(нСтрокаРС, ВыборкаТовары);
						
						//Запись в ТЧ ШтрихкодыУпаковок 
						стрШКупаковок = тчШКУпаковок.Добавить();
						стрШКупаковок.ШтрихкодУпаковки = ВыборкаТовары.ШтрихкодУпаковки;
						
						//Запись в ТЧ Товары
						стрТовары = тчТовары.Добавить();
						стрТовары.Номенклатура = ВыборкаТовары.Номенклатура;
						стрТовары.Характеристика = ВыборкаТовары.Характеристика;
						стрТовары.СтавкаНДС = ВыборкаТовары.СтавкаНДС;
						стрТовары.Упаковка = ВыборкаТовары.Упаковка;
						стрТовары.Цена = ВыборкаТовары.Цена;
						стрТовары.Количество = 1;
						стрТовары.КоличествоУпаковок = 1;
						стрТовары.КоличествоПотребительскихУпаковок = 1;							
						стрТовары.GTIN = ВыборкаТовары.GTIN;
						
						//ПересчитатьСтроку(стрТовары);
						
					КонецЦикла;
					
					Если Не ГруппироватьДокументыПоДате Тогда
						ПересчитатьТабличнуюЧасть(ДокВывода);
						ЗаписатьДокумент(ДокВывода, тзДляЗаписиВРС, ТекВнешняяСистема, ТекОрганизация, ВидДвижения);
					КонецЕсли;
					
				КонецЦикла;
				
				Если ГруппироватьДокументыПоДате Тогда
					ПересчитатьТабличнуюЧасть(ДокВывода);
					ЗаписатьДокумент(ДокВывода, тзДляЗаписиВРС, ТекВнешняяСистема, ТекОрганизация, ВидДвижения);
				КонецЕсли;
				
			КонецЦикла;	
		КонецЦикла;
	КонецЦикла;
	
	
КонецПроцедуры 

Процедура ОбработатьВыборкуВозвратВОборот(Выборка, ВидДвижения)

	текКомментарий = "Ввод в оборот кодов возвращенных через ";
	
	Пока Выборка.Следующий() Цикл
		ТекОрганизация = Выборка.Организация;
		ВыборкаВнешняяСистема = Выборка.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Пока ВыборкаВнешняяСистема.Следующий() Цикл
			ТекВнешняяСистема = ВыборкаВнешняяСистема.ВнешняяСистема;
			ВыборкаДатаОперации = ВыборкаВнешняяСистема.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			Пока ВыборкаДатаОперации.Следующий() Цикл 
				ГруппироватьДокументыПоДате = НайтиНастройкуГруппировки(текОрганизация, текВнешняяСистема);    // по-умолчанию ложь
				ТекДатаОперации = ВыборкаДатаОперации.ДатаОперации;
				ВыборкаНомерЗаказа = ВыборкаДатаОперации.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
				СтруктураШапки = Новый Структура;
				СтруктураШапки.Вставить("Дата", ТекДатаОперации);
				СтруктураШапки.Вставить("Организация", ТекОрганизация);
				СтруктураШапки.Вставить("Операция", ВидДвижения); 
				СтруктураШапки.Вставить("Ответственный", ПараметрыСеанса.ТекущийПользователь);
				СтруктураШапки.Вставить("ВидПродукции", Перечисления.ВидыПродукцииИС.Обувь);
				Если ГруппироватьДокументыПоДате Тогда
					СтруктураШапки.Вставить("Комментарий", текКомментарий + ТекВнешняяСистема + " за "+Формат(ТекДатаОперации, "ДЛФ=Д")); 
					ДокВозвата = Документы.ВозвратВОборотИСМП.СоздатьДокумент();
					ЗаполнитьЗначенияСвойств(ДокВозвата, СтруктураШапки);
					тзДляЗаписиВРС = ПолучитьТЗДляЗаписиВРС();
				КонецЕсли;
				Пока ВыборкаНомерЗаказа.Следующий() Цикл;
					текНомерЗаказа = ВыборкаНомерЗаказа.НомерЗаказа;
					ВыборкаТовары = ВыборкаНомерЗаказа.Выбрать();
					Если Не ГруппироватьДокументыПоДате Тогда
						ДокВозвата = Документы.ВозвратВОборотИСМП.СоздатьДокумент();
						ЗаполнитьЗначенияСвойств(ДокВозвата, СтруктураШапки);
						тзДляЗаписиВРС = ПолучитьТЗДляЗаписиВРС();
					КонецЕсли;
					
					тчТовары = ДокВозвата.Товары;
					
					текДатаЗаказа = Дата(1,1,1);
					Пока ВыборкаТовары.Следующий() Цикл
						Если НЕ ЗначениеЗаполнено(текДатаЗаказа) Тогда
							текДатаЗаказа = ВыборкаТовары.ДатаЗаказа;
							Если НЕ ГруппироватьДокументыПоДате Тогда
								ДокВозвата.Комментарий = текКомментарий + ТекВнешняяСистема + " по заказу №"+ текНомерЗаказа + " от " + Формат(текДатаЗаказа, "ДЛФ=Д");
							КонецЕсли;
						КонецЕсли;	
						//Делаем запись в ТЗ для заполнения данных В РС
						нСтрокаРС = тзДляЗаписиВРС.Добавить();
						ЗаполнитьЗначенияСвойств(нСтрокаРС, ВыборкаТовары);
						
						стрТовары = тчТовары.Добавить();
						стрТовары.Номенклатура = ВыборкаТовары.Номенклатура;
						стрТовары.Характеристика = ВыборкаТовары.Характеристика;
						стрТовары.КодМаркировки = ВыборкаТовары.ШтрихкодУпаковки;
						стрТовары.ВидПервичногоДокумента = Перечисления.ВидыПервичныхДокументовИСМП.Прочее;
						стрТовары.Оплачен = Истина;
						стрТовары.НаименованиеПервичногоДокумента = "Заказ покупателя";
						стрТовары.НомерПервичногоДокумента = ВыборкаТовары.НомерЗаказа;
						стрТовары.ДатаПервичногоДокумента = ВыборкаТовары.ДатаЗаказа;
						
						
					КонецЦикла;
					
					Если Не ГруппироватьДокументыПоДате Тогда
						ЗаписатьДокумент(ДокВозвата, тзДляЗаписиВРС, ТекВнешняяСистема, ТекОрганизация, ВидДвижения);
					КонецЕсли;
					
				КонецЦикла;
				
				Если ГруппироватьДокументыПоДате Тогда
					ЗаписатьДокумент(ДокВозвата, тзДляЗаписиВРС, ТекВнешняяСистема, ТекОрганизация, ВидДвижения);
				КонецЕсли;
				
				
			КонецЦикла;	
		КонецЦикла;
	КонецЦикла;	
	
КонецПроцедуры
#КонецОбласти

#Область СозданиеДокументов
Процедура СоздатьДокументыВыводаСГруппировкойПоДате(Выборка, ВидДвижения)
	
КонецПроцедуры

Процедура СоздатьДокументыВывода(Выборка, ВидДвижения)
	
	ТекОрганизация = Выборка.Организация;
	ТекВнешняяСистема = Выборка.ВнешняяСистема;
	
	ВыборкаДатаОперации = Выборка.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаДатаОперации.Следующий() Цикл
		текДатаОперации = ВыборкаДатаОперации.ДатаОперации;
		ВыборкаНомерЗаказа = ВыборкаДатаОперации.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Пока ВыборкаНомерЗаказа.Следующий() Цикл;
			текНомерЗаказа = ВыборкаНомерЗаказа.НомерЗаказа;
			ДетальныеЗаписи = ВыборкаНомерЗаказа.Выбрать();
			Пока ДетальныеЗаписи.Следующий() Цикл
				
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;

			
	
	
	
КонецПроцедуры


#КонецОбласти                               

#Область Служебные
Функция ПолучитьТекстЗапросаДвиженияКМ()
	
	Текст ="ВЫБРАТЬ
	       |	гф_ДвижениеКодовМаркировкиИзВнешнихСистем.Организация КАК Организация,
	       |	гф_ДвижениеКодовМаркировкиИзВнешнихСистем.ВнешняяСистема КАК ВнешняяСистема,
	       |	гф_ДвижениеКодовМаркировкиИзВнешнихСистем.Операция КАК Операция,
	       |	гф_ДвижениеКодовМаркировкиИзВнешнихСистем.ДатаОперации КАК ДатаОперации,
	       |	гф_ДвижениеКодовМаркировкиИзВнешнихСистем.НомерЗаказа КАК НомерЗаказа,
	       |	гф_ДвижениеКодовМаркировкиИзВнешнихСистем.ДатаЗаказа КАК ДатаЗаказа,
	       |	гф_ДвижениеКодовМаркировкиИзВнешнихСистем.ШтрихкодУпаковки КАК ШтрихкодУпаковки,
	       |	гф_ДвижениеКодовМаркировкиИзВнешнихСистем.Номенклатура КАК Номенклатура,
	       |	гф_ДвижениеКодовМаркировкиИзВнешнихСистем.Характеристика КАК Характеристика,
	       |	гф_ДвижениеКодовМаркировкиИзВнешнихСистем.Цена КАК Цена,
	       |	гф_ДвижениеКодовМаркировкиИзВнешнихСистем.GTIN КАК GTIN,
	       |	гф_ДвижениеКодовМаркировкиИзВнешнихСистем.ДокументОперацииКМ КАК ДокументОперацииКМ,
	       |	ШтрихкодыУпаковокТоваров.Упаковка КАК Упаковка,
	       |	спрНоменклатура.СтавкаНДС КАК СтавкаНДС
	       |ИЗ
	       |	РегистрСведений.гф_ДвижениеКодовМаркировкиИзВнешнихСистем КАК гф_ДвижениеКодовМаркировкиИзВнешнихСистем
	       |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
	       |		ПО гф_ДвижениеКодовМаркировкиИзВнешнихСистем.ШтрихкодУпаковки = ШтрихкодыУпаковокТоваров.Ссылка
	       |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК спрНоменклатура
	       |		ПО гф_ДвижениеКодовМаркировкиИзВнешнихСистем.Номенклатура = спрНоменклатура.Ссылка
	       |ГДЕ
	       |	(гф_ДвижениеКодовМаркировкиИзВнешнихСистем.ДокументОперацииКМ = НЕОПРЕДЕЛЕНО
	       |			ИЛИ гф_ДвижениеКодовМаркировкиИзВнешнихСистем.ДокументОперацииКМ = ЗНАЧЕНИЕ(Документ.ВозвратВОборотИСМП.ПустаяССылка)
	       |			ИЛИ гф_ДвижениеКодовМаркировкиИзВнешнихСистем.ДокументОперацииКМ = ЗНАЧЕНИЕ(Документ.ВыводИзОборотаИСМП.ПустаяССылка))
	       |	И гф_ДвижениеКодовМаркировкиИзВнешнихСистем.Операция = &ВыводИзОборота
	       |ИТОГИ ПО
	       |	Организация,
	       |	ВнешняяСистема,
	       |	ДатаОперации,
	       |	НомерЗаказа
	       |;
	       |
	       |////////////////////////////////////////////////////////////////////////////////
	       |ВЫБРАТЬ
	       |	гф_ДвижениеКодовМаркировкиИзВнешнихСистем.Организация КАК Организация,
	       |	гф_ДвижениеКодовМаркировкиИзВнешнихСистем.ВнешняяСистема КАК ВнешняяСистема,
	       |	гф_ДвижениеКодовМаркировкиИзВнешнихСистем.Операция КАК Операция,
	       |	гф_ДвижениеКодовМаркировкиИзВнешнихСистем.ДатаОперации КАК ДатаОперации,
	       |	гф_ДвижениеКодовМаркировкиИзВнешнихСистем.НомерЗаказа КАК НомерЗаказа,
	       |	гф_ДвижениеКодовМаркировкиИзВнешнихСистем.ДатаЗаказа КАК ДатаЗаказа,
	       |	гф_ДвижениеКодовМаркировкиИзВнешнихСистем.ШтрихкодУпаковки КАК ШтрихкодУпаковки,
	       |	гф_ДвижениеКодовМаркировкиИзВнешнихСистем.Номенклатура КАК Номенклатура,
	       |	гф_ДвижениеКодовМаркировкиИзВнешнихСистем.Характеристика КАК Характеристика,
	       |	гф_ДвижениеКодовМаркировкиИзВнешнихСистем.Цена КАК Цена,
	       |	гф_ДвижениеКодовМаркировкиИзВнешнихСистем.GTIN КАК GTIN,
	       |	ВЫРАЗИТЬ(гф_ДвижениеКодовМаркировкиИзВнешнихСистем.ДокументОперацииКМ КАК Документ.ВозвратВОборотИСМП) КАК ДокументОперацииКМ,
	       |	ШтрихкодыУпаковокТоваров.Упаковка КАК Упаковка,
	       |	спрНоменклатура.СтавкаНДС КАК СтавкаНДС
	       |ИЗ
	       |	РегистрСведений.гф_ДвижениеКодовМаркировкиИзВнешнихСистем КАК гф_ДвижениеКодовМаркировкиИзВнешнихСистем
	       |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
	       |		ПО гф_ДвижениеКодовМаркировкиИзВнешнихСистем.ШтрихкодУпаковки = ШтрихкодыУпаковокТоваров.Ссылка
	       |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК спрНоменклатура
	       |		ПО гф_ДвижениеКодовМаркировкиИзВнешнихСистем.Номенклатура = спрНоменклатура.Ссылка
	       |ГДЕ
	       |	(гф_ДвижениеКодовМаркировкиИзВнешнихСистем.ДокументОперацииКМ = НЕОПРЕДЕЛЕНО
	       |			ИЛИ гф_ДвижениеКодовМаркировкиИзВнешнихСистем.ДокументОперацииКМ = ЗНАЧЕНИЕ(Документ.ВозвратВОборотИСМП.ПустаяССылка)
	       |			ИЛИ гф_ДвижениеКодовМаркировкиИзВнешнихСистем.ДокументОперацииКМ = ЗНАЧЕНИЕ(Документ.ВыводИзОборотаИСМП.ПустаяССылка))
	       |	И гф_ДвижениеКодовМаркировкиИзВнешнихСистем.Операция = &ВозвратВОборот
	       |ИТОГИ ПО
	       |	Организация,
	       |	ВнешняяСистема,
	       |	ДатаОперации,
	       |	НомерЗаказа"; 
	
	Возврат Текст;
	
КонецФункции

Функция НайтиНастройкуГруппировки(Организация, ВнешняяСистема)
	
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("ВнешняяСистема", ВнешняяСистема);
	Запрос.Текст = "ВЫБРАТЬ
	               |	гф_НастройкиИнтеграцииСВнешнимиСистемамиПредопределенныеЗначения.Значение КАК Значение
	               |ИЗ
	               |	Справочник.гф_НастройкиИнтеграцииСВнешнимиСистемами.ПредопределенныеЗначения КАК гф_НастройкиИнтеграцииСВнешнимиСистемамиПредопределенныеЗначения
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.гф_НастройкиИнтеграцииСВнешнимиСистемами КАК гф_НастройкиИнтеграцииСВнешнимиСистемами
	               |		ПО гф_НастройкиИнтеграцииСВнешнимиСистемамиПредопределенныеЗначения.Ссылка = гф_НастройкиИнтеграцииСВнешнимиСистемами.Ссылка
	               |ГДЕ
	               |	гф_НастройкиИнтеграцииСВнешнимиСистемами.Организация = &Организация
	               |	И гф_НастройкиИнтеграцииСВнешнимиСистемами.ВнешняяСистема = &ВнешняяСистема
	               |	И НЕ гф_НастройкиИнтеграцииСВнешнимиСистемами.ПометкаУдаления
	               |	И гф_НастройкиИнтеграцииСВнешнимиСистемами.Использовать
	               |	И гф_НастройкиИнтеграцииСВнешнимиСистемамиПредопределенныеЗначения.Наименование = ""ГруппироватьДокументыДвиженияКМПоДате""";
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Значение;
	Иначе
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции

Функция ПолучитьТЗДляЗаписиВРС()
	
	тз = Новый ТаблицаЗначений;
	КолонкиТЗ = тз.Колонки;
	КолонкиТЗ.Добавить("ДатаОперации", ОбщегоНазначения.ОписаниеТипаДата(ЧастиДаты.ДатаВремя));
	КолонкиТЗ.Добавить("ДатаЗаказа", ОбщегоНазначения.ОписаниеТипаДата(ЧастиДаты.Дата));
	КолонкиТЗ.Добавить("НомерЗаказа", ОбщегоНазначения.ОписаниеТипаСтрока(150));
	КолонкиТЗ.Добавить("Организация", Новый ОписаниеТипов("СправочникСсылка.Организации"));
	КолонкиТЗ.Добавить("ВнешняяСистема", Новый ОписаниеТипов("ПеречислениеСсылка.гф_ВнешниеСистемы"));
	КолонкиТЗ.Добавить("ШтрихкодУпаковки", Новый ОписаниеТипов("СправочникСсылка.ШтрихкодыУпаковокТоваров"));
	КолонкиТЗ.Добавить("Номенклатура", Новый ОписаниеТипов("СправочникСсылка.Номенклатура")); 
	КолонкиТЗ.Добавить("Характеристика", Новый ОписаниеТипов("СправочникСсылка.ХарактеристикиНоменклатуры"));
	КолонкиТЗ.Добавить("Цена", ОбщегоНазначения.ОписаниеТипаЧисло(15,2));
	КолонкиТЗ.Добавить("Операция", Новый ОписаниеТипов("ПеречислениеСсылка.ВидыОперацийИСМП"));
	КолонкиТЗ.Добавить("ДокументОперацииКМ");
	КолонкиТЗ.Добавить("GTIN", ОбщегоНазначения.ОписаниеТипаСтрока(150));
	КолонкиТЗ.Добавить("КодМаркировкиСтрока", ОбщегоНазначения.ОписаниеТипаСтрока(250)); 
	КолонкиТЗ.Добавить("Комментарий", ОбщегоНазначения.ОписаниеТипаСтрока(100));
	
	Возврат тз;
	
КонецФункции

Процедура ЗаписатьДокумент(Объект, ТзРС, ВнешняяСистема, Организация, Операция)
	
	Попытка
		Объект.Записать(РежимЗаписиДокумента.Проведение);
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		ЗаписатьОшибкуВЖурналРегистрации(ТекстОшибки, Объект);
		ЗаписатьОшибкуВЛогОшибокОбменаСВнешнимиСистемами(ВнешняяСистема, Организация, Операция.Наименование,, "Ошибка проведения документа", ТекстОшибки);
		Объект.Комментарий = Объект.Комментарий + " " + ТекстОшибки;
		Объект.Записать(РежимЗаписиДокумента.Запись);
	КонецПопытки;
	
	Ссылка = Объект.Ссылка;
	тзРС.ЗаполнитьЗначения(Ссылка, "ДокументОперацииКМ");
	
	Для каждого стр из тзРС Цикл
		НаборЗаписей = РегистрыСведений.гф_ДвижениеКодовМаркировкиИзВнешнихСистем.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.ДатаОперации.Установить(стр.ДатаОперации);
		НаборЗаписей.Отбор.ДатаЗаказа.Установить(стр.ДатаЗаказа);
		НаборЗаписей.Отбор.НомерЗаказа.Установить(стр.НомерЗаказа);
		НаборЗаписей.Отбор.Организация.Установить(стр.Организация);
		НаборЗаписей.Отбор.ВнешняяСистема.Установить(стр.ВнешняяСистема);
		НаборЗаписей.Отбор.ШтрихкодУпаковки.Установить(стр.ШтрихкодУпаковки);
		НаборЗаписей.Отбор.Номенклатура.Установить(стр.Номенклатура);
		НаборЗаписей.Отбор.Характеристика.Установить(стр.Характеристика);
		НаборЗаписей.Отбор.Цена.Установить(стр.Цена);
		НаборЗаписей.Отбор.Операция.Установить(Операция);
		НаборЗаписей.Прочитать(); 
		Для каждого Набор из НаборЗаписей Цикл
			Набор.ДокументОперацииКМ = стр.ДокументОперацииКМ
		КонецЦикла;
		НаборЗаписей.Записать();
	КонецЦикла;
		
КонецПроцедуры 

Процедура ЗаписатьОшибкуВЖурналРегистрации(ТекстОшибки, Объект = Неопределено)
	
	МетаданныеОбъект = "";
	Если Объект <> Неопределено Тогда
		МетаданныеОбъект = Объект.Метаданные();
	КонецЕсли; 
	
	ЗаписьЖурналаРегистрации("Обмен с внешними системами. Загрузка продаж Cactus",УровеньЖурналаРегистрации.Ошибка,МетаданныеОбъект,?(Объект = Неопределено,NULL,Объект.Ссылка),ТекстОшибки);
	
конецПроцедуры

Процедура ЗаписатьОшибкуВЛогОшибокОбменаСВнешнимиСистемами(ВнешняяСистема, Организация, Операция, СтрокаНомер = 0, ТекстОшибки, Данные)

	мз = РегистрыСведений.гф_ОшибкиОбменаДаннымиСВнешнимиСистемами.СоздатьМенеджерЗаписи();
	мз.Дата = ТекущаяДатаСеанса();
	мз.Организация = Организация;
	мз.ВнешняяСистема = ВнешняяСистема;
	мз.Операция = Операция;
	мз.СтрокаНомер = СтрокаНомер;
	мз.ОписаниеОшибки = ТекстОшибки;
	мз.Данные = Данные;
	мз.Записать(Истина);
	
КонецПроцедуры

Процедура ПересчитатьТабличнуюЧасть(Объект)
	
	//СтруктураДействий = Новый Структура;
	//
	//СтруктураПересчетаСуммы = Новый Структура;
	//СтруктураПересчетаСуммы.Вставить("ЦенаВключаетНДС", Истина); 
	//СтруктураДействий.Вставить("ПересчитатьСуммуНДС", СтруктураПересчетаСуммы);
	//СтруктураДействий.Вставить("ПересчитатьСуммуСНДС", СтруктураПересчетаСуммы);
	//СтруктураДействий.Вставить("ПересчитатьСумму");
   
////    ОбработкаТабличнойЧастиКлиент.ОбработатьСтрокуТЧ(ТекСтрока, СтруктураДействий, Неопределено);

	
	СтруктураПересчета = Новый Структура;
	СтруктураПересчета.Вставить("ЦенаВключаетНДС", Истина);	
	СтруктураДействий = Новый Структура;
	СтруктураДействий.Вставить("ПересчитатьСумму");
	СтруктураДействий.Вставить("Количество");
	СтруктураДействий.Вставить("ПересчитатьСуммуНДС", СтруктураПересчета);
	СтруктураДействий.Вставить("ПересчитатьСуммуСНДС", СтруктураПересчета);
	////СтруктураДействий.Вставить("ЗаполнитьКодТНВЭД", Объект.НалогообложениеНДС);
	////Если ТипЗнч(Объект) = Тип("ДокументОбъект.РеализацияТоваровУслуг") Тогда
	////	СтруктураДействий.Вставить("ПересчитатьСуммуСУчетомРучнойСкидки", Новый Структура("Очищать", Истина));
	////	СтруктураДействий.Вставить("ПересчитатьСуммуСУчетомАвтоматическойСкидки", Новый Структура("Очищать", Истина));
	////	СтруктураДействий.Вставить("ОчиститьСуммуВзаиморасчетов");
	////КонецЕсли;
	ОбработкаТабличнойЧастиСервер.ОбработатьТЧ(Объект.Товары, СтруктураДействий, Неопределено);
	
КонецПроцедуры
#КонецОбласти