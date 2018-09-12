﻿Перем РазницаВМилисекундахМеждуЮниксИНачалЭпохи;
// { Plugin interface
Функция ОписаниеПлагина(ВозможныеТипыПлагинов) Экспорт
	Результат = Новый Структура;
	Результат.Вставить("Тип", ВозможныеТипыПлагинов.ГенераторОтчета);
	Результат.Вставить("Идентификатор", Метаданные().Имя);
	Результат.Вставить("Представление", "Отчет о тестировании в формате XML для Yandex Allure");
	
	Возврат Новый ФиксированнаяСтруктура(Результат);
КонецФункции

Процедура Инициализация(КонтекстЯдраПараметр) Экспорт
КонецПроцедуры
// } Plugin interface

// { Report generator interface
Функция СоздатьОтчет(КонтекстЯдра, РезультатыТестирования) Экспорт
	ПостроительДереваТестов = КонтекстЯдра.Плагин("ПостроительДереваТестов");
	ЭтотОбъект.ТипыУзловДереваТестов = ПостроительДереваТестов.ТипыУзловДереваТестов;
	ЭтотОбъект.ИконкиУзловДереваТестов = ПостроительДереваТестов.ИконкиУзловДереваТестов;
	ЭтотОбъект.СостоянияТестов = КонтекстЯдра.СостоянияТестов;
	Отчет = СоздатьОтчетНаСервере(РезультатыТестирования);
	
	Возврат Отчет;
КонецФункции

Функция СоздатьОтчетНаСервере(РезультатыТестирования) Экспорт
	
	ИмяФайла = ПолучитьИмяВременногоФайла("xsd");
	СхемаAllure = ПолучитьМакет("СхемаAllure");
	СхемаAllure.Записать(ИмяФайла);
	
	Фабрика = СоздатьФабрикуXDTO(ИмяФайла);
	
	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.УстановитьСтроку("UTF-8");
	ЗаписьXML.ЗаписатьОбъявлениеXML();
	
	НаборЗаписейXML = Новый Массив;
	
	ВывестиДанныеОтчетаТестированияРекурсивно(НаборЗаписейXML, ЗаписьXML, РезультатыТестирования, Фабрика, 1);
	
	РезНабор = Новый Массив;

	Для Каждого ЗаписьXML Из НаборЗаписейXML  Цикл
		
		СтрокаXML = ЗаписьXML.Закрыть();
		СтрокаXML = Allure_ПолучитьПреобразованнуюСтрокуXML(СтрокаXML);
		
		Отчет = Новый ТекстовыйДокумент;
		Отчет.ДобавитьСтроку(СтрокаXML);
		
		РезНабор.Добавить(Отчет);
	КонецЦикла; 
	
	Возврат РезНабор;
КонецФункции

Процедура ВывестиДанныеОтчетаТестированияРекурсивно(НаборЗаписейXML, ЗаписьXML, РезультатыТестирования, Фабрика, Знач Уровень, Знач Контейнер = Неопределено, Знач НаборТестов = Неопределено)

	ТекущийУровень = Уровень;
	Уровень = Уровень + 1;
	
	Если ТекущийУровень = 1 Тогда
			
		Для Каждого ЭлементКоллекции Из РезультатыТестирования.Строки Цикл
			ВывестиДанныеОтчетаТестированияРекурсивно(НаборЗаписейXML, ЗаписьXML, ЭлементКоллекции, Фабрика, Уровень, Контейнер, НаборТестов);
		КонецЦикла;
		
	ИначеЕсли РезультатыТестирования.Тип = ТипыУзловДереваТестов.Контейнер 
		И РезультатыТестирования.ИконкаУзла = ИконкиУзловДереваТестов.Обработка Тогда
			
		ТипTestSuiteResult = Фабрика.Тип("urn:model.allure.qatools.yandex.ru", "test-suite-result");
		Контейнер = Фабрика.Создать(ТипTestSuiteResult);
		
		Контейнер.name = РезультатыТестирования.Имя;
		
		Типlabels = Фабрика.Тип("urn:model.allure.qatools.yandex.ru", "labels");
		СписокМеток = Фабрика.Создать(Типlabels);
		СписокМеток.label.Добавить(Allure_ПолучитьМетку(Фабрика, "framework", "xUnitFor1C"));
		СписокМеток.label.Добавить(Allure_ПолучитьМетку(Фабрика, "language", "1С"));
		
		Контейнер.labels = СписокМеток;
		
		ТипTestCasesResult = Фабрика.Тип("urn:model.allure.qatools.yandex.ru", "test-cases-result");
		НаборТестов  = Фабрика.Создать(ТипTestCasesResult);
		
		Контейнер.test_cases = НаборТестов;
		
		Для Каждого ЭлементКоллекции Из РезультатыТестирования.Строки Цикл
			ВывестиДанныеОтчетаТестированияРекурсивно(НаборЗаписейXML, ЗаписьXML, ЭлементКоллекции, Фабрика, Уровень, Контейнер, НаборТестов);
		КонецЦикла;
		
		Фабрика.ЗаписатьXML(ЗаписьXML, Контейнер);
		
		НаборЗаписейXML.Добавить(ЗаписьXML);
		
		ЗаписьXML = Новый ЗаписьXML;
		ЗаписьXML.УстановитьСтроку("UTF-8");
		ЗаписьXML.ЗаписатьОбъявлениеXML();

	ИначеЕсли РезультатыТестирования.Тип = ТипыУзловДереваТестов.Элемент Тогда

		ТипTestCaseResult = Фабрика.Тип("urn:model.allure.qatools.yandex.ru", "test-case-result");
		Тест = Фабрика.Создать(ТипTestCaseResult);
		
		Тест.name = РезультатыТестирования.Представление;
		
		Тест.title = РезультатыТестирования.Представление;
		Тест.start = Число(РезультатыТестирования.ВремяНачала) - РазницаВМилисекундахМеждуЮниксИНачалЭпохи;
		Тест.stop  = Число(РезультатыТестирования.ВремяОкончания) - РазницаВМилисекундахМеждуЮниксИНачалЭпохи;
		Тест.status = Allure_ПолучитьСтатус(РезультатыТестирования.Состояние, СостоянияТестов);
		
		Если Тест.status = "broken" 
			ИЛИ Тест.status = "failed" Тогда
			
			СообщениеОбОшибке = УдалитьНедопустимыеСимволыXML(РезультатыТестирования.Сообщение);
			Тест.failure = Allure_ПолучитьОшибку(Фабрика, СообщениеОбОшибке);
			
			ТипParameters = Фабрика.Тип("urn:model.allure.qatools.yandex.ru", "parameters");
			НаборПараметров = Фабрика.Создать(ТипParameters);
			
			Сч = 1;
			Для Каждого ЭлементПараметр Из РезультатыТестирования.Параметры Цикл
				
				ПараметрТип = "environment-variable";
				ПараметрИмя = "Параметр " + Сч;
				ПараметрЗначение = Строка(ЭлементПараметр) + "(" + Строка(ТипЗнч(ЭлементПараметр)) + ")";
				
				Параметр = Allure_ПолучитьПараметр(Фабрика, ПараметрИмя, ПараметрЗначение, ПараметрТип);
				НаборПараметров.parameter.Добавить(Параметр);
				
				Сч = Сч + 1;
			КонецЦикла;
			
			Тест.parameters = НаборПараметров;
			
		КонецЕсли;
		
		Попытка
			НаборТестов.test_case.Добавить(Тест);
		Исключение
			Сообщить(РезультатыТестирования.Представление);
			ЗаписьЖурналаРегистрации("xUnitFor1C.ГенераторОтчетаAllureXML", УровеньЖурналаРегистрации.Ошибка, , , РезультатыТестирования.Представление);
			ВызватьИсключение;
		КонецПопытки;
		
	Иначе

		Для Каждого ЭлементКоллекции Из РезультатыТестирования.Строки Цикл
			ВывестиДанныеОтчетаТестированияРекурсивно(НаборЗаписейXML, ЗаписьXML, ЭлементКоллекции, Фабрика, Уровень, Контейнер, НаборТестов);
		КонецЦикла;
	
	КонецЕсли;

КонецПроцедуры

#Если ТолстыйКлиентОбычноеПриложение Тогда
Процедура Показать(Отчет) Экспорт
	Отчет.Показать();
КонецПроцедуры
#КонецЕсли

Процедура Экспортировать(Отчет, ПолныйПутьФайла) Экспорт

	СтрокаXML = Отчет.ПолучитьТекст();
	
	ИмяФайла = ПолныйПутьФайла;
	
	ИмяФайла = ПолучитьУникальноеИмяФайла(ИмяФайла); 
	
	Сообщение = "Уникальное имя файла " + ИмяФайла;
	ЗаписьЖурналаРегистрации("xUnitFor1C.ГенераторОтчетаAllureXML", УровеньЖурналаРегистрации.Информация, , , Сообщение);
	
	ПроверитьИмяФайлаРезультатаAllure(ИмяФайла);
	
	// Исключаем возможность записи в UTF-8 BOM
	ЗаписьТекста = Новый ЗаписьТекста(ИмяФайла, КодировкаТекста.ANSI);
	ЗаписьТекста.Закрыть();
	
	ЗаписьТекста = Новый ЗаписьТекста(ИмяФайла,,, Истина);
	КоличествоСтрок = СтрЧислоСтрок(СтрокаXML);
	Для НомерСтроки = 1 По КоличествоСтрок Цикл
		Стр = СтрПолучитьСтроку(СтрокаXML, НомерСтроки);
		ЗаписьТекста.ЗаписатьСтроку(Стр);
	КонецЦикла;
	ЗаписьТекста.Закрыть();

КонецПроцедуры
// } Report generator interface

// { Helpers

// Замена функции СтрШаблон на конфигурациях с режимом совместимости < 8.3.6
// При внедрении в конфигурацию с режимом совместимости >= 8.3.6 данную функцию необходимо удалить
//
Функция СтрШаблон_(Знач СтрокаШаблон, Знач Парам1 = Неопределено, Знач Парам2 = Неопределено, Знач Парам3 = Неопределено, Знач Парам4 = Неопределено) Экспорт
		
	МассивПараметров = Новый Массив;
	МассивПараметров.Добавить(Парам1);
	МассивПараметров.Добавить(Парам2);
	МассивПараметров.Добавить(Парам3);
	МассивПараметров.Добавить(Парам4);
	
	Для Сч = 1 По МассивПараметров.Количество() Цикл
		ТекЗначение = МассивПараметров[Сч-1];
		СтрокаШаблон = СтрЗаменить(СтрокаШаблон, "%"+Сч, Строка(ТекЗначение));
	КонецЦикла;
	Возврат СтрокаШаблон;
КонецФункции


// задаю уникальное имя для возможности получения одного отчета allure по разным тестовым наборам
Функция ПолучитьУникальноеИмяФайла(Знач ИмяФайла)
	Файл = Новый Файл(ИмяФайла);
	ГУИД = Новый УникальныйИдентификатор;
	ИмяФайла = СтрШаблон_("%1-%2-testsuite.xml", ГУИД, Файл.ИмяБезРасширения);
	ИмяФайла = СтрШаблон_("%1/%2", Файл.Путь, ИмяФайла); 
	Возврат ИмяФайла;
КонецФункции

Процедура ПроверитьИмяФайлаРезультатаAllure(ИмяФайла) Экспорт
	Сообщение = "";
	Файл = Новый Файл(ИмяФайла);
	Если Найти(Файл.Имя, "-testsuite") = 0 Тогда
		Сообщение = СтрШаблон_("%1
			|Файл-результат для Allure должен заканчиваться на ""-testsuite.xml""
			|Иначе Allure не покажет результаты тестирования
			|А сейчас имя файла %2", 
			Сообщение, Файл.ПолноеИмя);
	КонецЕсли;
	Если  Файл.Расширение <> ".xml" Тогда
		Сообщение = СтрШаблон_("%1
			|Файл-результат для Allure должен иметь расширение ""xml""
			|Иначе Allure не покажет результаты тестирования", 
			Сообщение);
	КонецЕсли;
	Если Не ПустаяСтрока (Сообщение) Тогда
		ВызватьИсключение Сообщение;
	КонецЕсли;
КонецПроцедуры

Функция УдалитьНедопустимыеСимволыXML(Знач Результат)
	Позиция = НайтиНедопустимыеСимволыXML(Результат);
	Пока Позиция > 0 Цикл
		Результат = Лев(Результат, Позиция - 1) + Сред(Результат, Позиция + 1);
		Позиция = НайтиНедопустимыеСимволыXML(Результат, Позиция);
	КонецЦикла;
	
	Возврат Результат;
КонецФункции

Функция Allure_ПолучитьПреобразованнуюСтрокуXML(Знач Строка)

	Строка = СтрЗаменить(Строка,"<test-suite-result","<ns2:test-suite");
	Строка = СтрЗаменить(Строка,"</test-suite-result>","</ns2:test-suite>");
	Строка = СтрЗаменить(Строка,"xmlns=""urn:model.allure.qatools.yandex.ru""","xmlns:ns2=""urn:model.allure.qatools.yandex.ru""");
	
	Возврат Строка;

КонецФункции

Функция Allure_ПолучитьМетку(Фабрика, Имя, Значение)

	Типlabel	= Фабрика.Тип("urn:model.allure.qatools.yandex.ru", "label");
	Метка		= Фабрика.Создать(Типlabel);
	Метка.name	= Имя;
	Метка.value = Значение;
	
	Возврат Метка;

КонецФункции

Функция Allure_ПолучитьПараметр(Фабрика, Имя, Значение, Тип)

	ТипParameter 	= Фабрика.Тип("urn:model.allure.qatools.yandex.ru", "parameter");
	Параметр 		= Фабрика.Создать(ТипParameter);
	Параметр.name  	= Имя;
	Параметр.value 	= Значение;
	Параметр.kind 	= Тип;
	
	Возврат Параметр;

КонецФункции

Функция Allure_ПолучитьОшибку(Фабрика, Знач СообщениеОбОшибке)

	ТипFailure		= Фабрика.Тип("urn:model.allure.qatools.yandex.ru", "failure");
	Ошибка			= Фабрика.Создать(ТипFailure);
	Ошибка.message	= СообщениеОбОшибке;	
	
	Возврат Ошибка;

КонецФункции

Функция Allure_ПолучитьСтатус(Состояние, СостоянияТестов)

	Статус = "failed";
	
	Если Состояние = СостоянияТестов.Пройден Тогда
		Статус = "passed";	
	ИначеЕсли Состояние = СостоянияТестов.НеРеализован Тогда
		Статус = "canceled";
	ИначеЕсли Состояние = СостоянияТестов.Сломан Тогда
		Статус = "broken";
	ИначеЕсли Состояние = СостоянияТестов.НеизвестнаяОшибка Тогда
		Статус = "failed";
	КонецЕсли;	
	
	Возврат Статус;

КонецФункции
// } Helpers

РазницаВМилисекундахМеждуЮниксИНачалЭпохи = 62135596800000;